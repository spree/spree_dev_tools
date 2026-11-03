# frozen_string_literal: true

require 'rails/generators'
require 'spree_dev_tools/openapi'

module SpreeDevTools
  # Sets an extension, or a Spree application, up to document its Admin API
  # endpoints, which makes each documented action an agent tool. In a Spree
  # project:
  #
  #   spree generate spree_dev_tools:openapi
  #
  # Writes spec/swagger_helper.rb and the agent-tool contract spec, then a
  # skeleton rswag spec for every admin action the extension's controllers
  # serve that its document does not describe yet. The skeletons are skipped
  # until filled in: each needs a description, which agents read, and the
  # records its response is tested against. Run it again after adding
  # endpoints; it writes only what is missing.
  class OpenapiGenerator < Rails::Generators::Base
    desc "Sets the extension up to generate openapi/admin.yaml and scaffolds rswag specs for undocumented admin actions"

    class_option :engine, type: :string, desc: 'The extension engine, e.g. MyExtension::Engine (detected when omitted)'

    CRUD_SUMMARIES = {
      'index' => 'List %<plural>s',
      'show' => 'Get a %<singular>s',
      'create' => 'Create a %<singular>s',
      'update' => 'Update a %<singular>s',
      'destroy' => 'Delete a %<singular>s'
    }.freeze

    RESPONSE_CODES = { 'create' => '201', 'destroy' => '204' }.freeze

    def set_destination
      self.destination_root = engine.root.to_s
    end

    def create_swagger_helper
      create_file 'spec/swagger_helper.rb', <<~RUBY, skip: true
        # frozen_string_literal: true

        # Integration specs that document the Admin API endpoints added here.
        # `spree task openapi:generate` (in an extension, `bundle exec rake
        # spree:openapi:generate`) writes them into openapi/admin.yaml, which
        # Spree reads to build an agent tool for each documented action.
        require '#{spec_helper}'
        require 'spree_dev_tools/rspec/openapi'
      RUBY
    end

    def create_contract_spec
      create_file 'spec/agent_tools_spec.rb', <<~RUBY, skip: true
        # frozen_string_literal: true

        require '#{spec_helper}'
        require 'spree/api/testing_support/agent_tools_contract'

        # Fails when an admin action has no documented operation, an opt-out has
        # no reason, or two actions would derive the same agent tool name.
        RSpec.describe 'agent tools' do
          it_behaves_like 'an engine whose admin writes are agent tools', #{reference}
        end
      RUBY
    end

    def scaffold_undocumented_operations
      missing = undocumented_routes
      if missing.empty?
        say_status :ok, 'every admin action is documented', :green
        return
      end

      missing.group_by { |route| route[:controller] }.each do |controller, routes|
        # Mirrors the controller's namespace under admin, so two controllers
        # with one name (an order's fulfillments and a seller's) never share
        # a file.
        relative = controller.controller_path.sub(%r{\Aspree/api/v3/admin/}, '')
        path = File.join('spec', 'integration', 'admin', "#{relative}_spec.rb")
        if File.exist?(File.join(destination_root, path))
          say_status :exists, "#{path}: add #{routes.map { |route| "#{route[:verb].upcase} #{route[:path]}" }.join(', ')}", :yellow
          next
        end

        create_file path, spec_for(controller, routes)
      end
    end

    private

    def reference
      options[:engine] || SpreeDevTools::Openapi.reference
    end

    # An application boots Rails from rails_helper; an extension's
    # spec_helper loads its dummy app.
    def spec_helper
      engine.is_a?(Rails::Application) ? 'rails_helper' : 'spec_helper'
    end

    def engine
      @engine ||= if options[:engine]
                    options[:engine].constantize
                  else
                    SpreeDevTools::Openapi.engine
                  end
    end

    # The engine's admin routes whose operation no document describes.
    def undocumented_routes
      Spree::Api::AdminDocument.reset!
      paths = Spree::Api::AdminDocument.document['paths'] || {}
      root = File.expand_path(engine.root.to_s)

      operations = Spree::Api::AgentOperations

      # What the contract spec requires: the actions that become tools. CRUD
      # reaches agents through the generic tools and needs no spec here.
      operations.admin_routes.select do |route|
        next false unless operations::WRITE_VERBS.include?(route[:verb]) && !operations::CRUD_ACTIONS.include?(route[:action])

        controller = route[:controller]
        location = controller && Object.const_source_location(controller.name)&.first
        location&.start_with?(root) && paths.dig(route[:path], route[:verb]).nil?
      end.uniq { |route| [route[:verb], route[:path]] }
    end

    def spec_for(controller, routes)
      model = model_for(controller)
      tag = model ? model.model_name.human.pluralize.titleize : controller.controller_name.titleize

      blocks = routes.group_by { |route| route[:path] }.map do |path, path_routes|
        operations = path_routes.map { |route| operation_for(controller, model, tag, route) }.join("\n\n")
        segments = path.scan(/\{([a-z_]+)\}/).flatten.map do |segment|
          named = segment == 'id' && model ? model.model_name.human : segment.delete_suffix('_id').humanize
          "    parameter name: :#{segment}, in: :path, type: :string, required: true, description: '#{named} ID'"
        end

        ["  path '#{path}' do", *segments, '', operations, '  end'].join("\n")
      end

      <<~RUBY
        # frozen_string_literal: true

        require 'swagger_helper'

        RSpec.describe '#{tag} Admin API', type: :request, swagger_doc: 'openapi/admin.yaml' do
          include_context 'API v3 Admin'

        #{blocks.join("\n\n")}
        end
      RUBY
    end

    def operation_for(controller, model, tag, route)
      action = route[:action]
      read = read_action?(controller, action)
      body = controller.respond_to?(:request_params_schema) && controller.request_params_schema(action)
      segments = route[:path].scan(/\{([a-z_]+)\}/).flatten

      lines = []
      lines << "    # TODO: check the summary; agents see it as the tool's name in words."
      lines << "    #{route[:verb]} '#{summary_for(action, model)}' do"
      lines << "      tags '#{tag}'"
      lines << "      admin_operation :#{read ? 'read' : 'write'}, :#{controller._scoped_resource || 'TODO'}, description: <<~DESC"
      lines << '        TODO: What this does and when to use it, for someone choosing the operation.'
      lines << '        Agents read this to decide whether to call it.'
      lines << '      DESC'
      lines << '      request_body_for' if body
      lines << ''
      lines << "      response '#{RESPONSE_CODES.fetch(action, '200')}', 'TODO' do"
      segments.each do |segment|
        lines << "        let(:#{segment}) { skip('TODO: the record this operation acts on') }"
      end
      lines << "        let(:body) { skip('TODO: a valid request body') }" if body
      lines << ''
      lines << '        run_test!'
      lines << '      end'
      lines << '    end'
      lines.join("\n")
    end

    def summary_for(action, model)
      singular = model ? model.model_name.human.downcase : 'record'
      template = CRUD_SUMMARIES[action]
      return format(template, singular: singular, plural: singular.pluralize) if template

      "#{action.humanize} a #{singular}"
    end

    def model_for(controller)
      Spree::Api::AgentResourceMap.model_for(controller)
    end

    # The scope kind the endpoint demands, by the controller's own rule.
    def read_action?(controller, action)
      instance = controller.allocate
      reads = instance.respond_to?(:read_actions, true) ? instance.send(:read_actions) : %w[index show]
      Array(reads).map(&:to_s).include?(action)
    rescue StandardError, NotImplementedError
      false
    end
  end
end
