# frozen_string_literal: true

module SpreeDevTools
  # Sets an extension's rswag specs up to generate the `openapi/admin.yaml`
  # its gem ships. Spree merges that file into the Admin API document its
  # agent tools are built from, so every action the extension documents is
  # a tool (see Spree's "MCP Server Custom Tools" guide).
  #
  # The same for a Spree application documenting admin endpoints of its own:
  # Spree reads the app's `openapi/admin.yaml` as it reads an extension's.
  #
  # In the extension's (or the app's) `spec/swagger_helper.rb`:
  #
  #   require 'spec_helper'
  #   require 'spree_dev_tools/rspec/openapi'
  #
  # The extension's engine is found from the directory the specs run in, and
  # in an application, where no engine's root is that directory, it is the
  # application itself. An extension with more than one engine, or a
  # different title, sets them before the require:
  #
  #   SpreeDevTools::Openapi.engine = MyExtension::Engine
  #   SpreeDevTools::Openapi.title = 'My Extension Admin API'
  module Openapi
    class << self
      attr_writer :engine, :title

      # @return [Rails::Engine, Rails::Application]
      def engine
        @engine ||= detect_engine || detect_application || raise(
          'spree_dev_tools could not tell which engine these specs document. ' \
          'Set SpreeDevTools::Openapi.engine = MyExtension::Engine before requiring spree_dev_tools/rspec/openapi.'
        )
      end

      # @return [String]
      def title
        @title ||= "#{name_of(engine).titleize} Admin API"
      end

      # How generated code refers to the engine: its class, or the
      # application, which is reached as Rails.application.
      #
      # @return [String]
      def reference
        engine.is_a?(Rails::Application) ? 'Rails.application' : engine.name
      end

      private

      def name_of(engine)
        engine.is_a?(Rails::Application) ? engine.class.module_parent_name.to_s : engine.engine_name.to_s
      end

      def detect_application
        root = File.expand_path(Dir.pwd)
        Rails.application if Rails.application && File.expand_path(Rails.application.root.to_s) == root
      end

      # The engine whose gem the specs run from.
      def detect_engine
        root = File.expand_path(Dir.pwd)
        Rails::Engine.descendants.reject { |klass| klass <= Rails::Application }.find do |klass|
          klass.root && File.expand_path(klass.root.to_s) == root
        end
      end
    end
  end
end
