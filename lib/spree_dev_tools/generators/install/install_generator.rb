require 'rails/generators'

module SpreeDevTools
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def self.source_paths
      paths = superclass.source_paths
      paths << File.expand_path('templates', __dir__)
      paths.flatten
    end

    desc 'Configures Rails generators for RSpec and FactoryBot'

    def run_rspec_install
      return if File.exist?(Rails.root.join('spec/spec_helper.rb'))

      rails_command 'rspec:install'
    end

    def install_spree_dev_tools
      return if File.exist?(Rails.root.join('config/initializers/spree_dev_tools.rb'))

      template 'spree_dev_tools.rb', 'config/initializers/spree_dev_tools.rb'
    end
  end
end
