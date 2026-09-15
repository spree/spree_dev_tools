# frozen_string_literal: true

module SpreeDevTools
  VERSION = '1.0.0.beta1'

  # Returns the version of the currently loaded SpreeDevTools as a
  # <tt>Gem::Version</tt>.
  def gem_version
    Gem::Version.new(VERSION)
  end
end
