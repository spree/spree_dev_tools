module SpreeDevTools
  VERSION = '0.5.2'

  # Returns the version of the currently loaded SpreeDevTools as a
  # <tt>Gem::Version</tt>.
  def gem_version
    Gem::Version.new(VERSION)
  end
end
