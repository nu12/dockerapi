RSpec.describe Docker::API::Response do
    it { expect(described_class).to be < Excon::Response }
    
    describe Docker::API::System.ping do
        it { is_expected.to respond_to(:json) }
        it { is_expected.to respond_to(:path) }
        it { is_expected.to respond_to(:success?) }
    end
end