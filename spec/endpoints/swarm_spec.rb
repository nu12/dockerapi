require 'socket'
RSpec.describe Docker::API::Swarm do
    ip_address = Socket.ip_address_list[2].ip_address

    subject { described_class.new }
    describe ".init" do
        it { expect(subject.init({AdvertiseAddr: "#{ip_address}:2377", ListenAddr: "0.0.0.0:4567", SubnetSize: 24, Spec: { Name: "must-be-default" }}).status).to eq(400) }
        it { expect(subject.init({AdvertiseAddr: "#{ip_address}:2377", ListenAddr: "0.0.0.0:4567", SubnetSize: 24, Spec: { Name: "default" }}).status).to eq(200) }
        it { expect(subject.init.status).to eq(503) }
        it { expect{subject.init(invalid: true)}.to raise_error(Docker::API::InvalidRequestBody) }
    end

    context "after .init" do
        describe ".details" do
            subject { described_class.new.details }
            it { expect(subject.status).to eq(200) }
            it { expect(subject.json["ID"]).not_to be nil }
            it { expect(subject.json["Version"]).not_to be nil }
            it { expect(subject.json["Version"]["Index"]).not_to be nil }
            it { expect(subject.json["JoinTokens"]).not_to be nil }
            it { expect(subject.json["JoinTokens"]["Worker"]).not_to be nil }
            it { expect(subject.json["JoinTokens"]["Manager"]).not_to be nil }
        end

        describe ".update" do
            it { expect(subject.update.status).to eq(400) }
            it { expect(subject.update({version: described_class.new.details.json["Version"]["Index"]}, {}).status).to eq(200) }
            it { expect(subject.update({version: described_class.new.details.json["Version"]["Index"], rotateWorkerToken: true}).status).to eq(200) }
            it { expect(subject.update({version: described_class.new.details.json["Version"]["Index"], rotateManagerToken: true}).status).to eq(200) }
            it { expect(subject.update({version: described_class.new.details.json["Version"]["Index"], rotateManagerUnlockKey: true}).status).to eq(200) }
            it { expect{subject.update({version: described_class.new.details.json["Version"]["Index"], invalid: true})}.to raise_error(Docker::API::InvalidParameter) }
            it { expect(subject.update({version: described_class.new.details.json["Version"]["Index"]}, {EncryptionConfig: { AutoLockManagers: true } }).status).to eq(200) }
            it { expect{subject.update({version: described_class.new.details.json["Version"]["Index"]},{invalid: true})}.to raise_error(Docker::API::InvalidRequestBody) }
        end
    
        describe ".unlock_key" do
            subject { described_class.new.unlock_key }
            it { expect(subject.status).to eq(200) }
            it { expect(subject.json["UnlockKey"]).not_to be nil }
        end
    
        describe ".unlock" do
            it { is_expected.to respond_to(:unlock) }
            it { expect(subject.unlock.status).to eq(409) }
        end
    
        describe ".join" do
            it { expect(subject.join.status).to eq(503) }
            it { expect(subject.join(RemoteAddrs: ["#{ip_address}:2377"], JoinToken: subject.details.json["JoinTokens"]["Worker"] ).status).to eq(503) }
        end
    
        describe ".leave" do
            it { expect(subject.leave.status).to eq(503) }
            it { expect(subject.leave(force: true).status).to eq(200) }
            it { expect{subject.leave(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end
    end
end