RSpec.describe Docker::API::Connection do
    it { expect(described_class.new).not_to be nil }
    it { expect(described_class.new.inspect).to match(/socket_key=\"unix:\/\/\/var\/run\/docker.sock\"/) }
    it { expect(described_class.new("http://localhost:2375").inspect).to match(/socket_key=\"http:\/\/localhost:2375\"/) }
    it { expect(Docker::API::System.new.ping.status).to eq(200) }
    it { expect(Docker::API::System.new(described_class.new("http://localhost:2375")).ping.status).to eq(200) }
end