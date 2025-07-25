RSpec.describe Docker::API::Config do
    name = "rspec-config"

    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:update) }
    it { is_expected.to respond_to(:delete) }

    context "with stubs" do
        before(:all) do     
            Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, { }) 
            Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :path => '/v1.43/configs/rspec-config', :port => 2375 }, {headers: {'Content-Type': 'application/json'}, body: '{"ID": "abc", "Version": {"Index": "abc"}}', status: 200 }) 
        end
        after(:all) { Excon.stubs.clear }

        describe ".list" do
            it { expect(subject.list.request_params[:path]).to eq('/v1.43/configs') }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            it { expect(subject.list(filters: {id: { "config-id": true }}).request_params[:path]).to eq('/v1.43/configs?filters={"id":{"config-id":true}}') }
            it { expect(subject.list(filters: {label: { "label=key": true }}).request_params[:path]).to eq('/v1.43/configs?filters={"label":{"label=key":true}}') }
            it { expect(subject.list(filters: {name: { "config-name": true }}).request_params[:path]).to eq('/v1.43/configs?filters={"name":{"config-name":true}}') }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".create" do
            it { expect(subject.create.request_params[:path]).to eq('/v1.43/configs/create') }
            it { expect(subject.create.request_params[:method]).to eq(:post) }
            it { expect(subject.create(Name: "rspec-config").request_params[:body]).to eq('{"Name":"rspec-config"}') }
            it { expect(subject.create({Name: "rspec-config",Labels: {foo: "bar"}, Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="}).request_params[:body]).to eq('{"Name":"rspec-config","Labels":{"foo":"bar"},"Data":"VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="}') }
            it { expect{subject.create(invalid: true)}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".details" do
            it { expect(subject.details("rspec-config").request_params[:path]).to eq('/v1.43/configs/rspec-config') }
            it { expect(subject.details("rspec-config").request_params[:method]).to eq(:get) }
            it { expect(subject.details("rspec-config").json["ID"]).not_to be(nil) }
            it { expect(subject.details("rspec-config").json["Version"]["Index"]).not_to be(nil) }
        end

        describe ".update" do
            let(:version) { subject.details("rspec-config").json["Version"]["Index"] }
            let(:spec) { subject.details("rspec-config").json["Spec"] }

            it { expect(subject.update("rspec-config", {version: version}, spec).request_params[:path]).to eq('/v1.43/v1.43/configs/rspec-config/update?version=abc') }
            it { expect(subject.update("rspec-config", {version: version}, spec).request_params[:method]).to eq(:post) }
            it { expect{subject.update("rspec-config", invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.update("rspec-config", {version: version}, {invalid: true})}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".delete" do
            it { expect(subject.delete("rspec-config").request_params[:path]).to eq('/v1.43/configs/rspec-config') }
            it { expect(subject.delete("rspec-config").request_params[:method]).to eq(:delete) }
        end
    end
end