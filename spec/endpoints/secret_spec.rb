RSpec.describe Docker::API::Secret do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:update) }
    it { is_expected.to respond_to(:delete) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".list" do
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets") }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            it { expect(subject.list(filters: {id: { "secret-id": true }}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets?filters={\"id\":{\"secret-id\":true}}") }
            it { expect(subject.list(filters: {label: { "label=key": true }}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets?filters={\"label\":{\"label=key\":true}}") }
            it { expect(subject.list(filters: {name: { "secret-name": true }}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets?filters={\"name\":{\"secret-name\":true}}") }
            it { expect(subject.list(filters: {names: { "secret-name": true }}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets?filters={\"names\":{\"secret-name\":true}}") }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.list(invalid: true, skip_validation: true)}.not_to raise_error }
        end

        describe ".create" do
            it { expect(subject.create({Name: "secret",Labels: {foo: "bar"}, Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets/create") }
            it { expect(subject.create({Name: "secret",Labels: {foo: "bar"}, Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="}).request_params[:method]).to eq(:post) }
            it { expect(subject.create({Name: "secret",Labels: {foo: "bar"}, Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="}).request_params[:body]).to eq("{\"Name\":\"secret\",\"Labels\":{\"foo\":\"bar\"},\"Data\":\"VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg==\"}") }
            it { expect(subject.create({Name: "secret",Labels: {foo: "bar"}, Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="}).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect{subject.create(invalid: true)}.to raise_error(Docker::API::InvalidRequestBody) }
            it { expect{subject.create(invalid: true, skip_validation: true)}.not_to raise_error }
        end

        describe ".details" do
            it { expect(subject.details("secret").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets/secret") }
            it { expect(subject.details("secret").request_params[:method]).to eq(:get) }
        end

        describe ".update" do
            it { expect(subject.update("secret", {version: "version"}, {}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets/secret/update?version=version") }
            it { expect(subject.update("secret", {version: "version"}, {}).request_params[:method]).to eq(:post) }
            it { expect(subject.update("secret", {version: "version"}, {}).request_params[:body]).to eq("{}") }
            it { expect(subject.update("secret", {version: "version"}, {}).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect{subject.update("secret", invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.update("secret", {version: "version"}, {invalid: true})}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".delete" do
            it { expect(subject.delete("secret").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/secrets/secret") }
            it { expect(subject.delete("secret").request_params[:method]).to eq(:delete) }
        end
    end
end