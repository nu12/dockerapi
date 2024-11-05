require "bundler/setup"
require "dockerapi"

Docker::API.print_to_stdout = false

Docker::API.print_response_to_stdout = false

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def get_api_ip_address
  
  Socket.ip_address_list.each do |addr|
    return addr.ip_address if addr.ipv4? && !addr.ipv4_loopback? && addr.ip_address =~ /\A\d{1,3}(\.\d{1,3}){3}\z/
  end

end