# frozen_string_literal: true

require "ruby_lsp/addon"

module RubyLsp
  module SpreeDevTools
    class Addon < ::RubyLsp::Addon
      SPREE_GEMS = %w[
        spree_core
        spree_api
        spree_admin
        spree_storefront
        spree_emails
      ].freeze

      def activate(global_state, outgoing_queue)
        @global_state = global_state
        @outgoing_queue = outgoing_queue
        @index = global_state.index

        # Index Spree app directories in a background thread
        Thread.new { index_spree_app_directories }
      end

      def deactivate; end

      def name
        "Ruby LSP Spree"
      end

      def version
        ::SpreeDevTools::VERSION
      end

      private

      def log(message)
        return unless @outgoing_queue

        @outgoing_queue << RubyLsp::Notification.window_log_message(message)
      end

      def index_spree_app_directories
        log("[Spree] Starting to index app/ directories from Spree gems...")

        indexed_count = 0

        SPREE_GEMS.each do |gem_name|
          count = index_gem_app_directory(gem_name)
          indexed_count += count if count
        end

        log("[Spree] Finished indexing #{indexed_count} files from Spree app/ directories")
      rescue => e
        log("[Spree] Error during indexing: #{e.message}")
      end

      def index_gem_app_directory(gem_name)
        spec = Gem::Specification.find_by_name(gem_name)
        app_path = File.join(spec.full_gem_path, "app")

        return 0 unless File.directory?(app_path)

        files = Dir.glob(File.join(app_path, "**", "*.rb"))
        log("[Spree] Indexing #{files.size} files from #{gem_name}/app/")

        files.each do |file_path|
          uri = URI::Generic.from_path(path: file_path)
          @index.index_file(uri, collect_comments: true)
        end

        files.size
      rescue Gem::MissingSpecError
        log("[Spree] Gem #{gem_name} not found, skipping")
        0
      rescue => e
        log("[Spree] Error indexing #{gem_name}: #{e.message}")
        0
      end
    end
  end
end
