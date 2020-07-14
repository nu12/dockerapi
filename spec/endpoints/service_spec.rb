RSpec.describe Docker::API::Service do
    service = "rspec-service"
    image = "busybox:1.31.1-uclibc"
    ip_address = Socket.ip_address_list[2].ip_address

    subject { described_class.new }
    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
    it { is_expected.to respond_to(:update) }
    it { is_expected.to respond_to(:logs) }
    it { expect(subject.list.status).to eq(503) }

    context "having a swarm cluster" do
        before(:all) { Docker::API::Swarm.new.init({AdvertiseAddr: "#{ip_address}:2377", ListenAddr: "0.0.0.0:4567"}) }
        after(:all) { Docker::API::Swarm.new.leave(force: true) }        
    
        describe ".list" do
            it { expect(subject.list.status).to eq(200) }
            it { expect(subject.list(filters: {id: ["9mnpnzenvg8p8tdbtq4wvbkcz"]}).status).to eq(200) }
            it { expect(subject.list(filters: {label: ["key=value"]}).status).to eq(200) }
            it { expect(subject.list(filters: {mode: ["replicated", "global"]}).status).to eq(200) }
            it { expect(subject.list(filters: {name: ["service-name"]}).status).to eq(200) }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".create" do
            it { expect(subject.create.status).to eq(400) }
            it { expect(subject.create({Name: service}).status).to eq(400) }
            it { expect(subject.create({Name: service, Labels: ["KEY=VALUE"]}).status).to eq(400) }
            
            it { expect(subject.create({Name: service, 
                TaskTemplate: {ContainerSpec: { Image: image }},
                Mode: { Replicated: { Replicas: 2 } },
                EndpointSpec: { Ports: [
                    {Protocol: "tcp", PublishedPort: 8080, TargetPort: 80}
                ] }
            }).status).to eq(201) }

            it { expect(subject.create({Name: service, TaskTemplate: {ContainerSpec: { Image: image }}}).status).to eq(409) }
            it { expect{subject.create({ invalid: true })}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        context "after .create" do
            describe ".details" do
                it { expect(subject.details( service ).status).to eq(200) }
                it { expect(subject.details( service, insertDefaults: true ).status).to eq(200) }
                it { expect(subject.details( "doesn-exist" ).status).to eq(404) }
                it { expect{subject.details( service, invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
            end

            describe ".logs" do
                it { expect(subject.logs( service ).status).to eq(500) }
                it { expect(subject.logs( service, details: true ).status).to eq(500) }
                it { expect(subject.logs( service, details: true, stdout: true ).status).to eq(200) }
                it { expect(subject.logs( service, details: true, stderr: true ).status).to eq(200) }
                it { expect(subject.logs( service, since: 0, stdout: true ).status).to eq(200) }
                it { expect(subject.logs( service, timestamps: 0, stdout: true ).status).to eq(200) }
                it { expect(subject.logs( service, tail: 10, stdout: true ).status).to eq(200) }
                it { expect(subject.logs( service, tail: "all", stdout: true ).status).to eq(200) }
                it { expect{subject.details( service, invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
            end

            describe ".update" do
                let(:spec) { subject.details(service).json["Spec"] }
                let(:version) { subject.details( service ).json["Version"]["Index"] }
                it { expect(subject.update(service).status).to eq(400) }
                it { expect(subject.update(service, {version: version}).status).to eq(400) }
                it { expect(subject.update(service, {version: version}, spec).status).to eq(200) }
                it { expect(subject.update(service, {version: version}, 
                        spec.merge!({TaskTemplate: {RestartPolicy: { Condition: "any", MaxAttempts: 2 }}, Mode: { Replicated: { Replicas: 1 } }})
                    ).status).to eq(200) }
                it { expect{subject.update(service, {version: version, invalid: true })}.to raise_error(Docker::API::InvalidParameter) }
                it { expect{subject.update(service, {version: version, invalid: true, skip_validation: true })}.not_to raise_error }
                it { expect{subject.update(service, {version: version}, { invalid: true })}.to raise_error(Docker::API::InvalidRequestBody) }
                it { expect{subject.update(service, {version: version}, { invalid: true, skip_validation: true })}.not_to raise_error }
                it { expect{subject.update(service, {version: version, invalid: true, skip_validation: true}, { invalid: true, skip_validation: true })}.not_to raise_error }
            end

            describe ".delete" do
                it { expect(subject.delete(service).status).to eq(200) }
                it { expect(subject.delete(service).status).to eq(404) }
            end
        end
    end
end