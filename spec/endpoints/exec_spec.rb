RSpec.describe Docker::API::Exec do
    image = "busybox:1.31.1-uclibc"
    container = "rspec-container"

    # A running container is needed

    before(:all) do
        Docker::API::Image.create(fromImage: image)
        Docker::API::Container.create({name: container}, {Image: image, Cmd: ["tail","-f","/dev/null"]})
        Docker::API::Container.start(container)
    end

    after(:all) do
        Docker::API::Container.stop(container)
        Docker::API::Container.remove(container)
        Docker::API::Image.remove(image)
    end

    describe "::create" do
        it { expect(described_class.create(container).status).to eq(400) }
        it { expect(described_class.create("doesn-exist", Cmd: ["ls", "-l"]).status).to eq(404) }
        it do 
            Docker::API::Container.pause(container)
            expect(described_class.create(container, Cmd: ["ls", "-l"]).status).to eq(409)
        end

        subject do 
            Docker::API::Container.unpause(container)
            described_class.create(container, Cmd: ["ls", "-l"])         
        end
        it { expect(subject.status).to eq(201) }
        it { expect(subject.json).not_to be(nil) }
        it { expect(subject.json["Id"]).not_to be(nil) }
        
    end
    context "after ::create" do 
        subject { described_class.create(container, AttachStdout:true, WorkingDir: "/etc", Cmd: ["ls", "-l"]) }
        describe "::start" do
            it { expect(described_class.start(subject.json["Id"]).status).to eq(200) }
            it { expect(described_class.start(subject.json["Id"]).data[:stream]).not_to be(nil) }
            it { expect(described_class.start("doesn-exist").status).to eq(404) }
        end
    
        describe "::resize" do
            #it { expect(described_class.resize(subject.json["Id"], h:100, w:100).status).to eq(201) }
            it { expect(described_class.resize(subject.json["Id"]).status).to eq(400) }
            it { expect(described_class.resize("doesn-exist", h:100, w:100).status).to eq(404) }
        end
    
        describe "::inspect" do
            it { expect(described_class.inspect(subject.json["Id"]).status).to eq(200) }
            it { expect(described_class.inspect("doesn-exist").status).to eq(404) }
        end

    end
end