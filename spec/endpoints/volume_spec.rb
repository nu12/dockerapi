RSpec.describe Docker::API::Volume do
    volume = "rspec-volume"

    describe "::list" do
        it { expect(described_class.list.status).to eq(200) }
        it { expect(described_class.list(filters: {dangling: {"true": true}}).status).to eq(200) }
        it { expect(described_class.list(filters: {driver: {"local": true}}).status).to eq(200) }
        it { expect(described_class.list(filters: {name: {"bridge": true}}).status).to eq(200) }
        it { expect{described_class.list( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        it { expect(described_class.list(filters: {invalid: {"true": true}}).status).to eq(400) }
    end

    describe "::create" do
        context "no name given" do
            subject { described_class.create }
            it { expect(subject.status).to eq(201) }
            it { expect(subject.json["Name"]).not_to eq(nil) }
        end
        it { expect(described_class.create(Name: volume, Driver: "local").status).to eq(201) }
        it { expect{described_class.create( invalid: true )}.to raise_error(Docker::API::InvalidRequestBody) }
    end

    describe "::inspect" do
        it { expect(described_class.inspect(volume).status).to eq(200) }
        it { expect(described_class.inspect("doesn-exist").status).to eq(404) }    
    end

    describe "::remove" do
        before(:each) { described_class.create(Name: volume, Driver: "local") }
        context "with container attached" do
            before(:all) do
                Docker::API::Image.create(fromImage: "busybox:1.31.1-uclibc")
                Docker::API::Container.create({name: "rspec-container"}, {Image: "busybox:1.31.1-uclibc", HostConfig: {Binds: ["#{volume}:/home"]}})
            end
            after(:all) do
                Docker::API::Container.remove("rspec-container")
                Docker::API::Image.remove("busybox:1.31.1-uclibc")
            end
            it { expect(described_class.remove(volume).status).to eq(409) }
            it { expect(described_class.remove(volume, force: true).status).to eq(409) }
        end
        it { expect(described_class.remove(volume).status).to eq(204) }
        it { expect(described_class.remove("doesn-exist").status).to eq(404) }
        it { expect{described_class.remove( volume, invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
    end

    describe "::prune" do
        it { expect(described_class.prune.status).to eq(200) }
        it { expect(described_class.prune( filters: {label: {"key": true}} ).status).to eq(200) }
        it { expect(described_class.prune( filters: {label: {"key=value": true}} ).status).to eq(200) }
        it { expect{described_class.prune( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
    end
end