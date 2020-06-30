RSpec.describe Docker::API::Connection do
    describe "is a Singleton" do
        subject {described_class.instance}
        
        it { expect(subject).not_to be nil }
        it { expect(subject).to be(described_class.instance) }
        it { expect(subject.inspect).to match(/docker.sock/) }
    end
end