
RSpec.describe Docker::API::Swarm do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:init) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:update) }
    it { is_expected.to respond_to(:unlock_key) }
    it { is_expected.to respond_to(:unlock) }
    it { is_expected.to respond_to(:join) }
    it { is_expected.to respond_to(:leave) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".init" do
            it { expect(subject.init({AdvertiseAddr: "127.0.0.1:2375", ListenAddr: "0.0.0.0:4567", SubnetSize: 24, Spec: { Name: "default" }}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/init") }
            it { expect(subject.init({AdvertiseAddr: "127.0.0.1:2375", ListenAddr: "0.0.0.0:4567", SubnetSize: 24, Spec: { Name: "default" }}).request_params[:method]).to eq(:post) }
            it { expect(subject.init({AdvertiseAddr: "127.0.0.1:2375", ListenAddr: "0.0.0.0:4567", SubnetSize: 24, Spec: { Name: "default" }}).request_params[:body]).to eq("{\"AdvertiseAddr\":\"127.0.0.1:2375\",\"ListenAddr\":\"0.0.0.0:4567\",\"SubnetSize\":24,\"Spec\":{\"Name\":\"default\"}}") }
            it { expect(subject.init({AdvertiseAddr: "127.0.0.1:2375", ListenAddr: "0.0.0.0:4567", SubnetSize: 24, Spec: { Name: "default" }}).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect{subject.init(invalid: true)}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".details" do
            it { expect(subject.details.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm") }
            it { expect(subject.details.request_params[:method]).to eq(:get) }
        end

        describe ".update" do
            it { expect(subject.update({version: "version"}, {}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/update?version=version") }
            it { expect(subject.update({version: "version"}, {}).request_params[:method]).to eq(:post) }
            it { expect(subject.update({version: "version", rotateWorkerToken: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/update?version=version&rotateWorkerToken=true") }
            it { expect(subject.update({version: "version", rotateManagerToken: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/update?version=version&rotateManagerToken=true") }
            it { expect(subject.update({version: "version", rotateManagerUnlockKey: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/update?version=version&rotateManagerUnlockKey=true") }
            it { expect{subject.update({version: "version", invalid: true})}.to raise_error(Docker::API::InvalidParameter) }
            it { expect(subject.update({version: "version"}, {EncryptionConfig: { AutoLockManagers: true } }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/update?version=version") }
            it { expect(subject.update({version: "version"}, {EncryptionConfig: { AutoLockManagers: true } }).request_params[:body]).to eq("{\"EncryptionConfig\":{\"AutoLockManagers\":true}}") }
            it { expect(subject.update({version: "version"}, {EncryptionConfig: { AutoLockManagers: true } }).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect{subject.update({version: "version"},{invalid: true})}.to raise_error(Docker::API::InvalidRequestBody) }
        end
    
        describe ".unlock_key" do
            it { expect(subject.unlock_key.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/unlockkey") }
            it { expect(subject.unlock_key.request_params[:method]).to eq(:get) }
        end
    
        describe ".unlock" do
            it { expect(subject.unlock.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/unlock") }
            it { expect(subject.unlock.request_params[:method]).to eq(:post) }
        end
    
        describe ".join" do
            it { expect(subject.join(RemoteAddrs: ["127.0.0.1:2377"], JoinToken: "token" ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/join") }
            it { expect(subject.join(RemoteAddrs: ["127.0.0.1:2377"], JoinToken: "token" ).request_params[:method]).to eq(:post) }
            it { expect(subject.join(RemoteAddrs: ["127.0.0.1:2377"], JoinToken: "token" ).request_params[:body]).to eq("{\"RemoteAddrs\":[\"127.0.0.1:2377\"],\"JoinToken\":\"token\"}") }
            it { expect(subject.join(RemoteAddrs: ["127.0.0.1:2377"], JoinToken: "token" ).request_params[:headers]["Content-Type"]).to eq("application/json") }
        end
    
        describe ".leave" do
            it { expect(subject.leave(force: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/swarm/leave?force=true") }
            it { expect(subject.leave(force: true).request_params[:method]).to eq(:post) }
            it { expect{subject.leave(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end
    end
end