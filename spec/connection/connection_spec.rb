RSpec.describe Docker::API::Connection do
    describe "is a Singleton" do
        let(:instance) {described_class.instance}

        it "::instance" do
            expect(instance).not_to be nil
            expect(instance).to be(described_class.instance)
        end

        it "#inspect" do
            expect(instance.inspect).to match(/docker.sock/)
        end

    end
end