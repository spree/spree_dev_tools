require 'rails/generators'

module SpreeDevTools
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def self.source_paths
      paths = superclass.source_paths
      paths << File.expand_path('templates', __dir__)
      paths << File.expand_path('../../rspec/support', __dir__)
      paths.flatten
    end

    desc 'Configures Rails generators for RSpec and FactoryBot'

    def run_rspec_install
      return if File.exist?(Rails.root.join('spec/spec_helper.rb'))

      rails_command 'generate rspec:install'
    end

    def install_spree_dev_tools
      return if File.exist?(Rails.root.join('config/initializers/spree_dev_tools.rb'))

      template 'spree_dev_tools.rb', 'config/initializers/spree_dev_tools.rb'
    end

    def inject_rspec_support_files
      empty_directory 'spec/support'

      template 'capybara.rb', 'spec/support/capybara.rb'
      template 'action_text.rb', 'spec/support/action_text.rb'
      template 'active_job.rb', 'spec/support/active_job.rb'
      template 'database_cleaner.rb', 'spec/support/database_cleaner.rb'
      template 'devise.rb', 'spec/support/devise.rb'
      template 'factory_bot.rb', 'spec/support/factory_bot.rb'
      template 'spree.rb', 'spec/support/spree.rb'
    end

    def enable_support_files_loading
      rails_helper_path = Rails.root.join('spec/rails_helper.rb')
      return unless File.exist?(rails_helper_path)

      gsub_file 'spec/rails_helper.rb',
                "# Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }",
                "Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }"
    end
  end
end
