# frozen_string_literal: true

# Sets an extension's or an application's rswag specs up to generate the
# `openapi/admin.yaml` it ships; see SpreeDevTools::Openapi. In
# `spec/swagger_helper.rb` (an application requires rails_helper instead):
#
#   require 'spec_helper'
#   require 'spree_dev_tools/rspec/openapi'
require 'rswag/specs'
begin
  require 'spree/api/testing_support/openapi'
rescue LoadError
  raise LoadError, 'spree_dev_tools/rspec/openapi needs a Spree whose spree_api ships ' \
                   'Spree::Api::TestingSupport::Openapi (the 6.0 patch release with agent tools from the Admin API document).'
end
require 'spree/api/testing_support/deterministic_openapi'
require 'spree_dev_tools/openapi'

RSpec.configure do |config|
  Spree::Api::TestingSupport::Openapi.configure(
    config, engine: SpreeDevTools::Openapi.engine, title: SpreeDevTools::Openapi.title
  )
end
