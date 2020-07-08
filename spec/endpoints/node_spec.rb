RSpec.describe Docker::API::Node do
    ip_address = Socket.ip_address_list[2].ip_address
    subject { described_class.new }
    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:inspect) }
    it { is_expected.to respond_to(:delete) }
    it { is_expected.to respond_to(:update) }
    it { expect(subject.list.status).to eq(503) }

    context "having a swarm cluster" do
        before(:all) { Docker::API::Swarm.new.init({AdvertiseAddr: "#{ip_address}:2377", ListenAddr: "0.0.0.0:4567"}) }
        after(:all) { Docker::API::Swarm.new.leave(force: true) }
        let(:id) { Docker::API::Node.new.list.json.first["ID"] }
        
    
        describe ".list" do
            it { expect(subject.list.status).to eq(200) }
            it { expect(subject.list(filters: {label: ["key=value"]}).status).to eq(200) }
            it { expect(subject.list(filters: {"node.label": ["key=value"]}).status).to eq(200) }
            it { expect(subject.list(filters: {membership: {"accepted": true}}).status).to eq(200) }
            it { expect(subject.list(filters: {membership: {"pending": true}}).status).to eq(200) }
            it { expect(subject.list(filters: {name: {"node_name": true}}).status).to eq(200) }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end
    
        describe ".inspect" do
            it { expect(subject.inspect(id).status).to eq(200) }
            it { expect(subject.inspect("doesn-exist").status).to eq(404) }
        end

        describe ".update" do
            let(:version) { Docker::API::Node.new.list.json.first["Version"]["Index"] }

            it { expect(subject.update(id, {version: version}, {Role: "manager", Availability: "drain" }).status).to eq(200) }
            it { expect(subject.update(id, {version: version}, {Role: "manager", Availability: "pause" }).status).to eq(200) }
            it { expect(subject.update(id, {version: version}, {Role: "manager", Availability: "active" }).status).to eq(200) }
            it { expect(subject.update(id, {version: version}, {Role: "worker", Availability: "active" }).data[:body]).to match(/attempting to demote the last manager of the swarm/) }
            it { expect(subject.update(id, {version: version}, {Name: "node-name", Role: "manager", Availability: "active" }).status).to eq(200) }
            it { expect(subject.update(id, {version: version}, {Labels: {"KEY": "VALUE"}, Role: "manager", Availability: "active" }).status).to eq(200) }
            it { expect(subject.update(id, {version: version}, {Name: "node-name" }).status).to eq(400) }
            it { expect(subject.update(id, {version: version}, {Labels: {"KEY": "VALUE"}}).status).to eq(400) }
            it { expect(subject.update(id, {version: version}, {Role: "manager"}).status).to eq(400) }
            it { expect(subject.update(id, {version: version}, {Role: "worker"}).status).to eq(400) }
            it { expect(subject.update(id, {version: version}, {Availability: "pause"}).status).to eq(400) }
            it { expect(subject.update(id, {version: version}, {Availability: "drain"}).status).to eq(400) }
            it { expect(subject.update(id, {version: version}, {Availability: "active"}).status).to eq(400) }
            it { expect{subject.update(id, {invalid: true}, {})}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.update(id, {version: version}, {invalid: true})}.to raise_error(Docker::API::InvalidRequestBody) }
        end    
    
        describe ".delete" do
            it { expect(subject.delete(id).status).to eq(400) }
            it { expect(subject.delete(id, force: true).status).to eq(400) }
            it { expect{subject.delete(id, invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

    end
end