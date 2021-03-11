# Run Coverage report
require 'rspec/rails'
require 'rspec/active_model/mocks'
require 'rspec/retry'
require 'ffaker'
require 'pry'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Infer an example group's spec type from the file location.
  config.infer_spec_type_from_file_location!

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  config.color = true
  config.default_formatter = 'doc'

  # Capybara javascript drivers require transactional fixtures set to false, and we use DatabaseCleaner
  # to cleanup after each test instead.  Without transactional fixtures set to false the records created
  # to setup a test will be unavailable to the browser, which runs under a separate server instance.
  config.use_transactional_fixtures = false

  config.fail_fast = ENV['FAIL_FAST'] || false
  config.order = 'random'

  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3
  end
end
