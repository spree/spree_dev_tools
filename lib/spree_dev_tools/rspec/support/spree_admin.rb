if defined?(Spree::Admin)
  require 'spree/admin/testing_support/capybara_utils'
  require 'spree/admin/testing_support/tom_select'

  RSpec.configure do |config|
    config.include Spree::Admin::TestingSupport::CapybaraUtils
    config.include Spree::Admin::TestingSupport::TomSelect
  end
end
