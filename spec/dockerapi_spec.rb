RSpec.describe Docker::API do
  it { expect(Docker::API::VERSION).not_to be nil }
end
