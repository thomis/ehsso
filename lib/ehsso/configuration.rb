module Ehsso

  class Configuration
    attr_accessor :module_key
    attr_accessor :base_uri
    attr_accessor :proxy

    def initialize
      @proxy       = nil
      @module_key  = ""
      @base_uri    = ""
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

end
