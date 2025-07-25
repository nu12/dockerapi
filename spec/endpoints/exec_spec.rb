RSpec.describe Docker::API::Exec do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:start) }
    it { is_expected.to respond_to(:resize) }
    it { is_expected.to respond_to(:details) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".create" do
            it { expect(subject.create("dockerapi", Cmd: ["ls", "-l"]).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/exec") }
            it { expect(subject.create("dockerapi", Cmd: ["ls", "-l"]).request_params[:method]).to eq(:post) }
            it { expect(subject.create("dockerapi", Cmd: ["ls", "-l"]).request_params[:body]).to eq('{"Cmd":["ls","-l"]}') }
            it { expect(subject.create("dockerapi", AttachStdout:true, WorkingDir: "/etc", Cmd: ["ls", "-l"]).request_params[:body]).to eq('{"AttachStdout":true,"WorkingDir":"/etc","Cmd":["ls","-l"]}') }
        end

        describe ".start" do
            it { expect(subject.start("id").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/exec/id/start") }
            it { expect(subject.start("id").request_params[:method]).to eq(:post) }
            it { expect(subject.start("id").request_params[:body]).to eq("{}") }
        end

        describe ".resize" do
            it { expect(subject.resize("id").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/exec/id/resize") }
            it { expect(subject.resize("id").request_params[:method]).to eq(:post) }
        end

        describe ".details" do
            it { expect(subject.details("id").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/exec/id/json") }
            it { expect(subject.details("id").request_params[:method]).to eq(:get) }
        end
    end
end