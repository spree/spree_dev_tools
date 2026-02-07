# frozen_string_literal: true

module SpreeDevTools
  VERSION = '0.6.0.rc1'

  # Returns the version of the currently loaded SpreeDevTools as a
  # <tt>Gem::Version</tt>.
  def gem_version
    Gem::Version.new(VERSION)
  end
end
