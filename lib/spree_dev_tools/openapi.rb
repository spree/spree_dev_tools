# frozen_string_literal: true

module SpreeDevTools
  # Sets an extension's rswag specs up to generate the `openapi/admin.yaml`
  # its gem ships. Spree merges that file into the Admin API document its
  # agent tools are built from, so every action the extension documents is
  # a tool (see Spree's "MCP Server Custom Tools" guide).
  #
  # In the extension's `spec/swagger_helper.rb`:
  #
  #   require 'spec_helper'
  #   require 'spree_dev_tools/rspec/openapi'
  #
  # The extension's engine is found from the directory the specs run in. An
  # extension with more than one engine, or a different title, sets them
  # before the require:
  #
  #   SpreeDevTools::Openapi.engine = MyExtension::Engine
  #   SpreeDevTools::Openapi.title = 'My Extension Admin API'
  module Openapi
    class << self
      attr_writer :engine, :title

      # @return [Class<Rails::Engine>]
      def engine
        @engine ||= detect_engine || raise(
          'spree_dev_tools could not tell which engine these specs document. ' \
          'Set SpreeDevTools::Openapi.engine = MyExtension::Engine before requiring spree_dev_tools/rspec/openapi.'
        )
      end

      # @return [String]
      def title
        @title ||= "#{engine.engine_name.to_s.titleize} Admin API"
      end

      private

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
