require 'rspec/rails'
require 'ffaker'

require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/factories'
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
require 'spree/api/testing_support/factories'
require 'spree/api/testing_support/v2/current_order'
require 'spree/api/testing_support/v2/platform_contexts'
require 'spree/api/testing_support/v2/serializers_params'
require 'spree/core/controller_helpers/strong_parameters'

module Spree
  module TestingSupport
    module ApiHelpers
      def json_response
        case body = JSON.parse(response.body)
        when Hash
          body.with_indifferent_access
        when Array
          body
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Spree::Admin::TestingSupport::CapybaraUtils
  config.include Spree::Admin::TestingSupport::TomSelect
  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller
  config.include Spree::TestingSupport::ImageHelpers
  config.include Spree::Core::ControllerHelpers::StrongParameters, type: :controller

  config.include JSONAPI::RSpec, type: :request # required for API v2 request specs
  config.include Spree::TestingSupport::ApiHelpers, type: :request

  config.before(:each) do
    Spree::Webhooks.disabled = true
    reset_spree_preferences
  end
end
