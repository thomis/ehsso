require "json"

require "ehsso/version"
require "ehsso/configuration"
require "ehsso/person"

# Only load the Rails engine if Rails is defined and loaded
if defined?(Rails::Engine)
  require "ehsso/engine"
end

module Ehsso
end
