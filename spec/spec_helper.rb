require "simplecov"
SimpleCov.start

require "bundler/setup"
require "ehsso"

# mock service
require_relative "models/service_ok"
require_relative "models/service_not_found"
require_relative "models/service_ok_json_issue"
require_relative "models/service_500_json_issue"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
