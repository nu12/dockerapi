RSpec.describe Docker::API::Task do
    ip_address = Socket.ip_address_list[2].ip_address

    subject { described_class.new }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:logs) }
    it { expect(subject.list.status).to eq(503) }

    context "having a swarm cluster" do
        before(:all) do 
                Docker::API::Swarm.new.init({AdvertiseAddr: "#{ip_address}:2377", ListenAddr: "0.0.0.0:4567"}) 
                Docker::API::Service.new.create({Name: "rspec-service", 
                    TaskTemplate: {ContainerSpec: { Image: "nginx:alpine" }, LogDriver: {Name: "json-file"}},
                    Mode: { Replicated: { Replicas: 2 } },
                    EndpointSpec: { Ports: [
                        {Protocol: "tcp", PublishedPort: 8080, TargetPort: 80}
                    ] }
                })
        end
        after(:all) do 
            Docker::API::Swarm.new.leave(force: true) 
            Docker::API::Image.new.prune(filters: {dangling: {"true": true}})
        end

        describe ".list" do
            it { expect(subject.list.status).to eq(200) }
            it { expect(subject.list(filters: { "desired-state": {"running": true} }).status).to eq(200) }
            it { expect(subject.list(filters: { "desired-state": {"shutdown": true} }).status).to eq(200) }
            it { expect(subject.list(filters: { "desired-state": {"accepted": true} }).status).to eq(200) }
            it { expect(subject.list(filters: { "id": {"id-here": true} }).status).to eq(200) }
            it { expect(subject.list(filters: { "name": {"task-name": true} }).status).to eq(200) }
            it { expect(subject.list(filters: { "node": {"if-doesn-exist": true} }).status).to eq(404) }
            it { expect(subject.list(filters: { "service": {"if-doesn-exist": true} }).status).to eq(404) }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.list(invalid: true, skip_validation: true)}.not_to raise_error }
        end

        describe ".details" do
            it { expect(subject.details(subject.list.json.first["ID"]).status).to eq(200) }
            it { expect(subject.details("doesn-exist").status).to eq(404) }
        end

        describe ".logs" do
            let(:id) { subject.list.json.first["ID"] }
            it { expect(subject.logs( id ).status).to eq(500) }
            it { expect(subject.logs( id, details: true ).status).to eq(500) }
            it { expect(subject.logs( id, details: true, stdout: true ).status).to eq(200) }
            it { expect(subject.logs( id, details: true, stderr: true ).status).to eq(200) }
            it { expect(subject.logs( id, since: 0, stdout: true ).status).to eq(200) }
            it { expect(subject.logs( id, timestamps: 0, stdout: true ).status).to eq(200) }
            it { expect(subject.logs( id, tail: 10, stdout: true ).status).to eq(200) }
            it { expect(subject.logs( id, tail: "all", stdout: true ).status).to eq(200) }
            it { expect{subject.logs( id, invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.logs( id, invalid: true, skip_validation: true )}.not_to raise_error }
        end

        
    end

end