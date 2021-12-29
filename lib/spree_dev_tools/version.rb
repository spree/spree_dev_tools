module SpreeDevTools
  VERSION = '0.2.0'

  # Returns the version of the currently loaded SpreeDevTools as a
  # <tt>Gem::Version</tt>.
  def gem_version
    Gem::Version.new(VERSION)
  end
end
