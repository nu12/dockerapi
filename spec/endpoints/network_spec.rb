RSpec.describe Docker::API::Network do

    subject { described_class.new }
    describe ".list" do 
        it { expect(subject.list.status).to eq(200) }
        it { expect(subject.list(filters: { dangling: {"true": true} }).status).to eq(200) }
        it { expect(subject.list(filters: { driver: {"bridge": true} }).status).to eq(200) }
        it { expect(subject.list(filters: { name: {"bridge": true} }).status).to eq(200) }
        it { expect(subject.list(filters: { scope: {"local": true} }).status).to eq(200) }
        it { expect(subject.list(filters: { type: {"custom": true} }).status).to eq(200) }
        it { expect(subject.list(filters: { type: {"builtin": true} }).status).to eq(200) }
        it { expect{subject.list( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
    end

    describe ".details" do 
        it { expect(subject.details( "bridge" ).status).to eq(200) }
        it { expect(subject.details( "doesn-exist" ).status).to eq(404) }
        it { expect(subject.details( "bridge", verbose: true ).status).to eq(200) }
        it { expect(subject.details( "bridge", scope: "local" ).status).to eq(200) }
        it { expect{subject.details( "bridge", invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
    end

    describe ".create" do 
        it { expect(subject.create.status).to eq(500) }
        it do 
            expect(subject.create( 
                Name: "rspec-network",
                CheckDuplicate: true,
                Driver: "bridge",
                Internal: true,
                Attachable: true,
                EnableIPv6: false
                ).status).to eq(201)
        end
        it { expect{subject.create( invalid: true )}.to raise_error(Docker::API::InvalidRequestBody) }
        
    end

    context "having a container to connect" do
        before(:all) do
            Docker::API::Image.new.create(fromImage: "busybox:1.31.1-uclibc")
            Docker::API::Container.new.create({name: "rspec-container"}, {Image: "busybox:1.31.1-uclibc"} )
        end
        after(:all) do
            Docker::API::Container.new.remove("rspec-container")
            Docker::API::Image.new.remove("busybox:1.31.1-uclibc")
        end

        describe ".connect" do 
            it { expect(subject.connect("rspec-network").status).to eq(400) }
            it { expect(subject.connect("rspec-network", Container: "rspec-container").status).to eq(200) }
            it { expect{subject.connect( "rspec-network",  invalid: true )}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".disconnect" do 
            it { expect(subject.disconnect("rspec-network").status).to eq(400) }
            it do
                subject.connect("rspec-network", Container: "rspec-container")
                expect(subject.disconnect("rspec-network", Container: "rspec-container", Force: true).status).to eq(200)
            end
            it { expect(subject.disconnect("rspec-network", Container: "doesn-exist").status).to eq(404) }
            it { expect(subject.disconnect("doesn-exist", Container: "rspec-container").status).to eq(500) }
            it { expect{subject.disconnect( "rspec-network",  invalid: true )}.to raise_error(Docker::API::InvalidRequestBody)   }
        end
    end

    describe ".remove" do 
        it { expect(subject.remove( "rspec-network" ).status).to eq(204) }
        it { expect(subject.remove( "doesn-exist" ).status).to eq(404) }
    end

    describe ".prune" do 
        it { expect(subject.prune.status).to eq(200) }
        it { expect(subject.prune(filters: { until: {"10m": true} }).status).to eq(200) }
        it { expect(subject.prune(filters: { until: {"1h30m": true} }).status).to eq(200) }
        it { expect(subject.prune(filters: { label: {"key=value": true} }).status).to eq(200) }
        it { expect{subject.prune( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
    end
end