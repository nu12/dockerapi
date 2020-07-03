RSpec.describe Docker::API::Connection do
    describe "is a Singleton" do
        subject {described_class.instance}
        
        it { expect(subject).not_to be nil }
        it { expect(subject).to be(described_class.instance) }
        it { expect(subject.inspect).to match(/socket_key=\"unix:\/\/\/var\/run\/docker.sock\"/) }
        it { expect{subject.connect_to("http://localhost:2375")}.not_to raise_error }
        it { expect(subject.inspect).to match(/socket_key=\"http:\/\/localhost:2375\"/) }
        it { expect(Docker::API::System.ping.status).to eq(200) }
    end
end