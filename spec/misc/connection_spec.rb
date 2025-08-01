RSpec.describe Docker::API::Connection do
    it { expect(described_class.new).not_to be nil }
    it { expect(described_class.new.inspect).to match(/socket_key=\"unix:\/\/\/var\/run\/docker.sock\"/) }
    it { expect(described_class.new("http://localhost:2375").inspect).to match(/socket_key=\"http:\/\/localhost:2375\"/) }
    it { expect{Docker::API::System.new(Excon.new("http://localhost:2375"))}.to raise_error(Docker::API::Error, "Expected connection to be a Docker::API::Connection class") }

    context "with stubs" do
        subject {Docker::API::System.new(stub_connection)}
        before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :path => '/v1.43/_ping', :port => 2375 }, { status: 200 }) }
        after(:all) { Excon.stubs.clear }
        it { expect(subject.ping.status).to eq(200) }

    end
end