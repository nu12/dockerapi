RSpec.describe Docker::API::Volume do
    volume = "rspec-volume"

    subject { described_class.new }

    describe ".list" do
        it { expect(subject.list.status).to eq(200) }
        it { expect(subject.list(filters: {dangling: {"true": true}}).status).to eq(200) }
        it { expect(subject.list(filters: {driver: {"local": true}}).status).to eq(200) }
        it { expect(subject.list(filters: {name: {"bridge": true}}).status).to eq(200) }
        it { expect{subject.list( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        it { expect(subject.list(filters: {invalid: {"true": true}}).status).to eq(400) }
    end

    describe ".create" do
        context "no name given" do
            subject { described_class.new.create }
            it { expect(subject.status).to eq(201) }
            it { expect(subject.json["Name"]).not_to eq(nil) }
        end
        it { expect(subject.create(Name: volume, Driver: "local").status).to eq(201) }
        it { expect{subject.create( invalid: true )}.to raise_error(Docker::API::InvalidRequestBody) }
    end

    describe ".details" do
        it { expect(subject.details(volume).status).to eq(200) }
        it { expect(subject.details("doesn-exist").status).to eq(404) }    
    end

    describe ".remove" do
        before(:each) { subject.create(Name: volume, Driver: "local") }
        context "with container attached" do
            before(:all) do
                Docker::API::Image.new.create(fromImage: "busybox:1.31.1-uclibc")
                Docker::API::Container.new.create({name: "rspec-container"}, {Image: "busybox:1.31.1-uclibc", HostConfig: {Binds: ["#{volume}:/home"]}})
            end
            after(:all) do
                Docker::API::Container.new.remove("rspec-container")
                Docker::API::Image.new.remove("busybox:1.31.1-uclibc")
            end
            it { expect(subject.remove(volume).status).to eq(409) }
            it { expect(subject.remove(volume, force: true).status).to eq(409) }
        end
        it { expect(subject.remove(volume).status).to eq(204) }
        it { expect(subject.remove("doesn-exist").status).to eq(404) }
        it { expect{subject.remove( volume, invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
    end

    describe ".prune" do
        it { expect(subject.prune.status).to eq(200) }
        it { expect(subject.prune( filters: {label: {"key": true}} ).status).to eq(200) }
        it { expect(subject.prune( filters: {label: {"key=value": true}} ).status).to eq(200) }
        it { expect{subject.prune( invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
    end
end