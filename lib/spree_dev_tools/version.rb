module SpreeDevTools
  module_function

  # Returns the version of the currently loaded SpreeDevTools as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 1
    TINY  = 1

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end
end
