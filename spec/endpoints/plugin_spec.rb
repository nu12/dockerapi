RSpec.describe Docker::API::Plugin do
    subject { described_class.new(stub_connection) }
    
    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:privileges) }
    it { is_expected.to respond_to(:install) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:remove) }
    it { is_expected.to respond_to(:enable) }
    it { is_expected.to respond_to(:disable) }
    it { is_expected.to respond_to(:upgrade) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:push) }
    it { is_expected.to respond_to(:configure) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".list" do
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins") }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            it { expect(subject.list(filters: {capability: { "name": true }}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins?filters={\"capability\":{\"name\":true}}") }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".privileges" do
            it { expect(subject.privileges(remote: "remote").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/privileges?remote=remote") }
            it { expect(subject.privileges(remote: "remote").request_params[:method]).to eq(:get) }
            it { expect{subject.privileges(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".install" do
            it { expect(subject.install(remote: "plugin", name: "local-name").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/pull?remote=plugin&name=local-name") }
            it { expect(subject.install(remote: "plugin", name: "local-name").request_params[:method]).to eq(:post) }
            it { expect(subject.install({remote: "plugin", name: "local-name"}, {a: "b"}).request_params[:body]).to eq("{\"a\":\"b\"}") }
            it { expect(subject.install({remote: "plugin", name: "local-name"}, {a: "b"}).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect(subject.install({remote: "plugin", name: "local-name"}, {a: "b"}, {username: "janedoe", password: "password"}).request_params[:headers]["X-Registry-Auth"]).to eq("eyJ1c2VybmFtZSI6ImphbmVkb2UiLCJwYXNzd29yZCI6InBhc3N3b3JkIn0=") }
            it { expect{subject.install(remote: "plugin", invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".details" do
            it { expect(subject.details("plugin").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/plugin/json") }
            it { expect(subject.details("plugin").request_params[:method]).to eq(:get) }
        end

        describe ".configure" do
            it { expect(subject.configure("plugin", ["DEBUG=1"]).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/plugin/set") }
            it { expect(subject.configure("plugin", ["DEBUG=1"]).request_params[:method]).to eq(:post) }
            it { expect(subject.configure("plugin", ["DEBUG=1"]).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect(subject.configure("plugin", ["DEBUG=1"]).request_params[:body]).to eq("[\"DEBUG=1\"]") } 
        end

        describe ".enable" do
            it { expect(subject.enable("plugin", timeout: 0).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/plugin/enable?timeout=0") }
            it { expect(subject.enable("plugin", timeout: 0).request_params[:method]).to eq(:post) }
            it { expect{subject.enable("plugin", invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            
        end

        describe ".disable" do
            it { expect(subject.disable("plugin").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/plugin/disable") }
            it { expect(subject.disable("plugin").request_params[:method]).to eq(:post) }
        end

        describe ".upgrade" do
            it { expect(subject.upgrade("plugin", {remote: "remote"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/plugin/upgrade?remote=remote") }
            it { expect(subject.upgrade("plugin", {remote: "remote"}).request_params[:method]).to eq(:post) }
            it { expect(subject.upgrade("plugin", {remote: "remote"}).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect(subject.upgrade("plugin", {remote: "remote"}, nil, {username: "janedoe", password: "password"}).request_params[:headers]["X-Registry-Auth"]).to eq("eyJ1c2VybmFtZSI6ImphbmVkb2UiLCJwYXNzd29yZCI6InBhc3N3b3JkIn0=") }
            it { expect(subject.upgrade("plugin", {remote: "remote"}, nil, {username: "janedoe", password: "password"}).request_params[:body]).to eq("null") }
            it { expect{subject.upgrade("plugin", remote: "remote", invalid: true)}.to raise_error(Docker::API::InvalidParameter) } 
        end

        describe ".remove" do
            it { expect(subject.remove("plugin").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/plugin") }
            it { expect(subject.remove("plugin").request_params[:method]).to eq(:delete) }
            it { expect(subject.remove("plugin", force: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/plugin?force=true") }
            it { expect{subject.remove("plugin", invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".create" do
            before(:all) { File.write("plugin.tar", "\u0000") }
            after(:all) { File.delete(File.expand_path("plugin.tar")) }
            it { expect(subject.create("myplugin", "plugin.tar").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/create?name=myplugin") }
            it { expect(subject.create("myplugin", "plugin.tar").request_params[:method]).to eq(:post) }
            it { expect(subject.create("myplugin", "plugin.tar").request_params[:body]).to eq("\u0000") }
        end

        describe ".push" do
            it { expect(subject.push("myplugin").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/plugins/myplugin/push") }
            it { expect(subject.push("myplugin").request_params[:method]).to eq(:post) }
            it { expect(subject.push("myplugin", {username: "janedoe", password: "password"}).request_params[:headers]["X-Registry-Auth"]).to eq("eyJ1c2VybmFtZSI6ImphbmVkb2UiLCJwYXNzd29yZCI6InBhc3N3b3JkIn0=") }
        end
    end
end