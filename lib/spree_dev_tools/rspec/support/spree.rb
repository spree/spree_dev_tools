# Requires factories and other useful helpers defined in spree_core.
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/flash'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/order_walkthrough'
require 'spree/testing_support/auth_helpers'
require 'spree/testing_support/checkout_helpers'
require 'spree/testing_support/caching'

# API v2 helpers
if defined?(Spree::Api) && Spree.version.to_f >= 3.7
  require 'jsonapi/rspec'
  require 'spree/api/testing_support/v2/base'
  require 'spree/api/testing_support/v2/current_order'
end

RSpec.configure do |config|
  # Infer an example group's spec type from the file location.
  config.infer_spec_type_from_file_location!

  # == URL Helpers
  #
  # Allows access to Spree's routes in specs:
  #
  # visit spree.admin_path
  # current_path.should eql(spree.products_path)
  config.include Spree::TestingSupport::UrlHelpers

  # == Requests support
  #
  # Adds convenient methods to request Spree's controllers
  # spree_get :index
  config.include Spree::TestingSupport::ControllerRequests, type: :controller

  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::Flash

  config.include Spree::TestingSupport::AuthHelpers, type: :feature
  config.include Spree::TestingSupport::CheckoutHelpers, type: :feature

  if Spree.version.to_f >= 3.7
    config.include JSONAPI::RSpec, type: :request # required for API v2 request specs
  end

  config.before :each do
    I18n.locale = :en
    Rails.cache.clear

    country = create(:country, name: 'United States of America', iso_name: 'UNITED STATES', iso: 'US', states_required: true)

    reset_spree_preferences

    if Spree.version.to_f >= 4.2
      create(:store, default: true, default_country: country)
    else
      create(:store, default: true)
    end
  end
end
