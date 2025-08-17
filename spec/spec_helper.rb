require "bundler/setup"
require "dockerapi"

Docker::API.print_to_stdout = false

Docker::API.print_response_to_stdout = false

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.filter_run_excluding :e2e

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def stub_connection  
  return Docker::API::Connection.new('http://127.0.0.1:2375', {mock: true})
end