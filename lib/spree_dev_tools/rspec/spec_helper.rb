# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV['RAILS_ENV'] ||= 'test'

require 'rspec/rails'
require 'database_cleaner/active_record'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'ffaker'
require 'pry'

require 'webdrivers/chromedriver'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/factories'
require 'spree/api/testing_support/factories'
require 'spree/testing_support/preferences'
require 'spree/testing_support/jobs'
require 'spree/testing_support/store'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/order_walkthrough'
require 'spree/admin/testing_support/capybara_utils'
require 'spree/admin/testing_support/tom_select'
require 'spree/testing_support/capybara_config'
require 'spree/testing_support/rspec_retry_config'
require 'spree/testing_support/image_helpers'

require 'jsonapi/rspec'
require 'spree/api/testing_support/v2/base'
require 'spree/api/testing_support/matchers/webhooks'
require 'spree/api/testing_support/v2/current_order'
require 'spree/api/testing_support/v2/platform_contexts'
require 'spree/api/testing_support/v2/serializers_params'

require 'spree/core/controller_helpers/strong_parameters'

require 'action_text/system_test_helper'

RSpec.configure do |config|
  config.color = true
  config.default_formatter = 'doc'
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.raise_errors_for_deprecations!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before(:suite) do
    Capybara.match = :smart
    Capybara.javascript_driver = :selenium_chrome_headless
    Capybara.default_max_wait_time = 10
    Capybara.raise_server_errors = false
    # Clean out the database state before the tests run
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before(:each) do
    Spree::Webhooks.disabled = true
    reset_spree_preferences
  end

  config.include FactoryBot::Syntax::Methods

  config.include Spree::Admin::TestingSupport::CapybaraUtils
  config.include Spree::Admin::TestingSupport::TomSelect
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::TestingSupport::ImageHelpers

  config.include Spree::Core::ControllerHelpers::StrongParameters, type: :controller

  config.include ActionText::SystemTestHelper, type: :feature

  config.include JSONAPI::RSpec, type: :request # required for API v2 request specs
  config.include Spree::TestingSupport::ApiHelpers, type: :request

  config.order = :random
  Kernel.srand config.seed

  config.filter_run_including focus: true unless ENV['CI']
  config.run_all_when_everything_filtered = true
end
