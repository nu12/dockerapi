RSpec.describe Docker::API::Volume do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:remove) }
    it { is_expected.to respond_to(:prune) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".list" do
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes") }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            it { expect(subject.list(filters: {dangling: {"true": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes?filters={\"dangling\":{\"true\":true}}") }
            it { expect(subject.list(filters: {driver: {"local": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes?filters={\"driver\":{\"local\":true}}") }
            it { expect(subject.list(filters: {name: {"bridge": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes?filters={\"name\":{\"bridge\":true}}") }
            it { expect{subject.list( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".create" do
            it { expect(subject.create(Name: "dockerapi", Driver: "local").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes/create") }
            it { expect(subject.create(Name: "dockerapi", Driver: "local").request_params[:method]).to eq(:post) }
            it { expect(subject.create(Name: "dockerapi", Driver: "local").request_params[:body]).to eq("{\"Name\":\"dockerapi\",\"Driver\":\"local\"}") }
            it { expect(subject.create(Name: "dockerapi", Driver: "local").request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect{subject.create( invalid: true )}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".details" do
            it { expect(subject.details("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes/dockerapi") }
            it { expect(subject.details("dockerapi").request_params[:method]).to eq(:get) }
        end

        describe ".remove" do
            it { expect(subject.remove("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes/dockerapi") }
            it { expect(subject.remove("dockerapi").request_params[:method]).to eq(:delete) }
            it { expect{subject.remove( "dockerapi", invalid: true )}.to raise_error(Docker::API::InvalidParameter) } 
        end

        describe ".prune" do
            it { expect(subject.prune.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes/prune") }
            it { expect(subject.prune.request_params[:method]).to eq(:post) }
            it { expect(subject.prune( filters: {label: {"key": true}} ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes/prune?filters={\"label\":{\"key\":true}}") }
            it { expect(subject.prune( filters: {label: {"key=value": true}} ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/volumes/prune?filters={\"label\":{\"key=value\":true}}") }
            it { expect{subject.prune( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        end
    end
end