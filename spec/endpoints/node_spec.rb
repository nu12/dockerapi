RSpec.describe Docker::API::Node do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:delete) }
    it { is_expected.to respond_to(:update) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".list" do
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes") }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            it { expect(subject.list(filters: {label: ["key=value"]}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes?filters={\"label\":[\"key=value\"]}") }
            it { expect(subject.list(filters: {"node.label": ["key=value"]}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes?filters={\"node.label\":[\"key=value\"]}") }
            it { expect(subject.list(filters: {membership: {"accepted": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes?filters={\"membership\":{\"accepted\":true}}") }
            it { expect(subject.list(filters: {membership: {"pending": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes?filters={\"membership\":{\"pending\":true}}") }
            it { expect(subject.list(filters: {name: {"node_name": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes?filters={\"name\":{\"node_name\":true}}") }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end
    
        describe ".details" do
            it { expect(subject.details("id").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes/id") }
            it { expect(subject.details("id").request_params[:method]).to eq(:get) }
        end

        describe ".update" do
            it { expect(subject.update("id", {version: "version"}, {Role: "manager", Availability: "drain" }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes/id/update?version=version") }
            it { expect(subject.update("id", {version: "version"}, {Role: "manager", Availability: "pause" }).request_params[:method]).to eq(:post) }
            it { expect(subject.update("id", {version: "version"}, {Role: "manager", Availability: "active" }).request_params[:body]).to eq("{\"Role\":\"manager\",\"Availability\":\"active\"}") }
            it { expect(subject.update("id", {version: "version"}, {Role: "manager", Availability: "drain" }).request_params[:headers][:"Content-Type"]).to eq("application/json") }
            it { expect(subject.update("id", {version: "version"}, {Name: "node-name", Role: "manager", Availability: "active" }).request_params[:body]).to eq("{\"Name\":\"node-name\",\"Role\":\"manager\",\"Availability\":\"active\"}") }
            it { expect(subject.update("id", {version: "version"}, {Labels: {"KEY": "VALUE"}, Role: "manager", Availability: "active" }).request_params[:body]).to eq("{\"Labels\":{\"KEY\":\"VALUE\"},\"Role\":\"manager\",\"Availability\":\"active\"}") }
            it { expect{subject.update("id", {invalid: true}, {})}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.update("id", {version: "version"}, {invalid: true})}.to raise_error(Docker::API::InvalidRequestBody) }
        end    
    
        describe ".delete" do
            it { expect(subject.delete("id").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes/id") }
            it { expect(subject.delete("id").request_params[:method]).to eq(:delete) }
            it { expect(subject.delete("id", force: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/nodes/id?force=true") }
            it { expect{subject.delete("id", invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

    end
end