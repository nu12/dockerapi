RSpec.describe Docker::API::Secret do
    ip_address = get_api_ip_address
    name = "rspec-secret"

    subject { described_class.new }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:update) }
    it { is_expected.to respond_to(:delete) }

    it { expect(subject.list.status).to eq(503) }

    context "having a swarm cluster" do
        before(:all) { Docker::API::Swarm.new.init({AdvertiseAddr: "#{ip_address}:2377", ListenAddr: "0.0.0.0:4567"}) }
        after(:all) { Docker::API::Swarm.new.leave(force: true) }

        describe ".list" do
            it { expect(subject.list.status).to eq(200) }
            it { expect(subject.list(filters: {id: { "secret-id": true }}).status).to eq(200) }
            it { expect(subject.list(filters: {label: { "label=key": true }}).status).to eq(200) }
            it { expect(subject.list(filters: {name: { "secret-name": true }}).status).to eq(200) }
            it { expect(subject.list(filters: {names: { "secret-name": true }}).status).to eq(200) }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.list(invalid: true, skip_validation: true)}.not_to raise_error }
        end

        describe ".create" do
            it { expect(subject.create.status).to eq(400) }
            it { expect(subject.create(Name: name).status).to eq(400) }
            it { expect(subject.create({Name: name,Labels: {foo: "bar"},
                Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="}).status).to eq(201) }
            it { expect(subject.create({Name: name, Data: "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="}).status).to eq(409) }
            it { expect{subject.create(invalid: true)}.to raise_error(Docker::API::InvalidRequestBody) }
            it { expect{subject.create(invalid: true, skip_validation: true)}.not_to raise_error }
        end

        context "after .create" do
            describe ".details" do
                it { expect(subject.details(name).status).to eq(200) }
                it { expect(subject.details("doesn-exist").status).to eq(404) }
                it { expect(subject.details(name).json["ID"]).not_to be(nil) }
                it { expect(subject.details(name).json["Version"]["Index"]).not_to be(nil) }
            end

            describe ".update" do
                let(:version) { subject.details(name).json["Version"]["Index"] }
                let(:spec) { subject.details(name).json["Spec"] }

                it { expect(subject.update("doesn-exist", {version: version}, spec).status).to eq(404) }
                it { expect(subject.update(name, {version: version}, spec).status).to eq(200) }
                it { expect{subject.update(name, invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
                it { expect{subject.update(name, {version: version}, {invalid: true})}.to raise_error(Docker::API::InvalidRequestBody) }

            end

            describe ".delete" do
                it { expect(subject.delete(name).status).to eq(204) }
                it { expect(subject.delete(name).status).to eq(404) }
            end
        end

    end

end