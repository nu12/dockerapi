RSpec.describe Docker::API::Response do
    it { expect(described_class).to be < Excon::Response }
    
    context "with stubs" do
        subject {Docker::API::System.new(stub_connection)}
        before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, { status: 200 }) }
        after(:all) { Excon.stubs.clear }
        it { expect(subject.ping).to respond_to(:json) }
        it { expect(subject.ping).to respond_to(:path) }
        it { expect(subject.ping).to respond_to(:success?) }
        it { expect(subject.ping).to respond_to(:request_params) }
        it { expect(subject.ping.request_params[:path]).to eq('/v1.43/_ping') }
    end
end