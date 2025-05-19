# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_dev_tools/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_dev_tools'
  s.version     = SpreeDevTools::VERSION
  s.summary     = 'Spree Dev Tools'
  s.description = 'Spree Developer Tools'
  s.required_ruby_version = '>= 2.3.0'

  s.author    = 'Spark Solutions'
  s.email     = 'we@sparksolutions.co'
  s.homepage  = 'https://github.com/spree/spree_dev_tools'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'appraisal'
  s.add_dependency 'awesome_print'
  s.add_dependency 'brakeman'
  s.add_dependency 'capybara'
  s.add_dependency 'capybara-screenshot'
  s.add_dependency 'capybara-select-2'
  s.add_dependency 'database_cleaner'
  s.add_dependency 'factory_bot', '~> 4.7'
  s.add_dependency 'ffaker'
  s.add_dependency 'gem-release'
  s.add_dependency 'github_changelog_generator'
  s.add_dependency 'jsonapi-rspec'
  s.add_dependency 'pry'
  s.add_dependency 'puma'
  s.add_dependency 'rails-controller-testing'
  s.add_dependency 'rspec-activemodel-mocks'
  s.add_dependency 'rspec_junit_formatter'
  s.add_dependency 'rspec-rails'
  s.add_dependency 'rspec-retry'
  s.add_dependency 'rubocop'
  s.add_dependency 'rubocop-rails'
  s.add_dependency 'sass-rails'
  s.add_dependency 'selenium-webdriver'
  s.add_dependency 'simplecov'
  s.add_dependency 'spree'
  s.add_dependency 'timecop'
  s.add_dependency 'webdrivers'
end
