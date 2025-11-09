require 'action_text/system_test_helper'

RSpec.configure do |config|
  config.include ActionText::SystemTestHelper, type: :feature
end
