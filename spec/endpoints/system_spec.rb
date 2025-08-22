RSpec.describe Docker::API::System do
    subject { described_class.new(stub_connection) } 

    it { is_expected.to respond_to(:auth) }
    it { is_expected.to respond_to(:ping) }
    it { is_expected.to respond_to(:info) }
    it { is_expected.to respond_to(:version) }
    it { is_expected.to respond_to(:events) }
    it { is_expected.to respond_to(:df) }
    
    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".auth" do
            it { expect(subject.auth(username: "janedoe", password: "password", email: "janedow@email.com", serveraddress: "docker.io", identitytoken: "token").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/auth") }
            it { expect(subject.auth(username: "janedoe", password: "password", email: "janedow@email.com", serveraddress: "docker.io", identitytoken: "token").request_params[:method]).to eq(:post) }
            it { expect(subject.auth(username: "janedoe", password: "password", email: "janedow@email.com", serveraddress: "docker.io", identitytoken: "token").request_params[:body]).to eq("{\"username\":\"janedoe\",\"password\":\"password\",\"email\":\"janedow@email.com\",\"serveraddress\":\"docker.io\",\"identitytoken\":\"token\"}") }
            it { expect(subject.auth(username: "janedoe", password: "password", email: "janedow@email.com", serveraddress: "docker.io", identitytoken: "token").request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect{subject.auth(username: "janedoe", password: "password", email: "janedow@email.com", serveraddress: "docker.io", identitytoken: "token")}.not_to raise_error }
            it { expect{subject.auth(invalid: true)}.to raise_error(Docker::API::InvalidRequestBody) }
            it { expect{subject.auth(invalid: true, skip_validation: true)}.not_to raise_error }
        end

        describe ".ping" do
            it { expect(subject.ping.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/_ping") }
            it { expect(subject.ping.request_params[:method]).to eq(:get) }
        end

        describe ".info" do
            it { expect(subject.info.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/info") }
            it { expect(subject.info.request_params[:method]).to eq(:get) }
        end

        describe ".version" do
            it { expect(subject.version.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/version") }
            it { expect(subject.version.request_params[:method]).to eq(:get) }
        end

        describe ".events" do
            let(:now) { Time.now.to_i }
            it { expect(subject.events.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/events") }
            it { expect(subject.events.request_params[:method]).to eq(:get) }
            it { expect(subject.events(until: now).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/events?until=#{now}") }
            it { expect{subject.events(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.events(invalid: true, skip_validation: false)}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".df" do
            it { expect(subject.df.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/system/df") }
            it { expect(subject.df.request_params[:method]).to eq(:get) }
            it { expect(subject.df(type: "container").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/system/df?type=container" )}
            it { expect{subject.df(invalid: "true")}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.df(type: "container")}.not_to raise_error }
            
        end
    end
end