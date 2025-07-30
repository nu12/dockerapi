RSpec.describe Docker::API::Network do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:connect) }
    it { is_expected.to respond_to(:disconnect) }
    it { is_expected.to respond_to(:remove) }
    it { is_expected.to respond_to(:prune) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".list" do 
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks") }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            it { expect(subject.list(filters: { dangling: {"true": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks?filters={\"dangling\":{\"true\":true}}") }
            it { expect(subject.list(filters: { driver: {"bridge": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks?filters={\"driver\":{\"bridge\":true}}") }
            it { expect(subject.list(filters: { name: {"bridge": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks?filters={\"name\":{\"bridge\":true}}") }
            it { expect(subject.list(filters: { scope: {"local": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks?filters={\"scope\":{\"local\":true}}") }
            it { expect(subject.list(filters: { type: {"custom": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks?filters={\"type\":{\"custom\":true}}") }
            it { expect(subject.list(filters: { type: {"builtin": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks?filters={\"type\":{\"builtin\":true}}") }
            it { expect{subject.list( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".details" do 
            it { expect(subject.details( "bridge" ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/bridge") }
            it { expect(subject.details( "bridge" ).request_params[:method]).to eq(:get) }
            it { expect(subject.details( "bridge", verbose: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/bridge?verbose=true") }
            it { expect(subject.details( "bridge", scope: "local" ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/bridge?scope=local") }
            it { expect{subject.details( "bridge", invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".create" do 
            it { expect(subject.create( Name: "rspec-network",CheckDuplicate: true,Driver: "bridge",Internal: true,Attachable: true,EnableIPv6: false).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/create") }
            it { expect(subject.create( Name: "rspec-network",CheckDuplicate: true,Driver: "bridge",Internal: true,Attachable: true,EnableIPv6: false).request_params[:method]).to eq(:post) }
            it { expect(subject.create( Name: "rspec-network",CheckDuplicate: true,Driver: "bridge",Internal: true,Attachable: true,EnableIPv6: false).request_params[:body]).to eq("{\"Name\":\"rspec-network\",\"CheckDuplicate\":true,\"Driver\":\"bridge\",\"Internal\":true,\"Attachable\":true,\"EnableIPv6\":false}") }
            it { expect(subject.create( Name: "rspec-network",CheckDuplicate: true,Driver: "bridge",Internal: true,Attachable: true,EnableIPv6: false).request_params[:headers][:"Content-Type"]).to eq("application/json") }
            it { expect{subject.create( invalid: true )}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".connect" do 
            it { expect(subject.connect("rspec-network", Container: "rspec-container").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/rspec-network/connect") }
            it { expect(subject.connect("rspec-network", Container: "rspec-container").request_params[:method]).to eq(:post) }
            it { expect(subject.connect("rspec-network", Container: "rspec-container").request_params[:body]).to eq("{\"Container\":\"rspec-container\"}") }
            it { expect(subject.connect("rspec-network", Container: "rspec-container").request_params[:headers][:"Content-Type"]).to eq("application/json") }
            it { expect{subject.connect( "rspec-network",  invalid: true )}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".disconnect" do 
            it { expect(subject.disconnect("rspec-network", Container: "rspec-container").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/rspec-network/disconnect") }
            it { expect(subject.disconnect("rspec-network", Container: "rspec-container").request_params[:method]).to eq(:post) }
            it { expect(subject.disconnect("rspec-network", Container: "rspec-container").request_params[:body]).to eq("{\"Container\":\"rspec-container\"}") }
            it { expect(subject.disconnect("rspec-network", Container: "rspec-container").request_params[:headers][:"Content-Type"]).to eq("application/json") }
            it { expect{subject.disconnect( "rspec-network",  invalid: true )}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".remove" do 
            it { expect(subject.remove("rspec-network").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/rspec-network") }
            it { expect(subject.remove("rspec-network").request_params[:method]).to eq(:delete) }
        end

        describe ".prune" do 
            it { expect(subject.prune.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/prune") }
            it { expect(subject.prune.request_params[:method]).to eq(:post) }
            it { expect(subject.prune(filters: { until: {"10m": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/prune?filters={\"until\":{\"10m\":true}}") }
            it { expect(subject.prune(filters: { until: {"1h30m": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/prune?filters={\"until\":{\"1h30m\":true}}") }
            it { expect(subject.prune(filters: { label: {"key=value": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/networks/prune?filters={\"label\":{\"key=value\":true}}") }
            it { expect{subject.prune( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        end
    end
end