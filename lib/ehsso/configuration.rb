module Ehsso
  class Configuration
    attr_accessor :module_key
    attr_accessor :base_url
    attr_accessor :username_and_password

    def initialize
      @module_key = ""
      @base_url = ""
      @username_and_password = nil
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
