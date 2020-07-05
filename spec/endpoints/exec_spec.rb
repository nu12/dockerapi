RSpec.describe Docker::API::Exec do
    image = "busybox:1.31.1-uclibc"
    container = "rspec-container"

    # A running container is needed

    before(:all) do
        Docker::API::Image.new.create(fromImage: image)
        Docker::API::Container.new.create({name: container}, {Image: image, Cmd: ["tail","-f","/dev/null"]})
        Docker::API::Container.new.start(container)
    end

    after(:all) do
        Docker::API::Container.new.stop(container)
        Docker::API::Container.new.remove(container)
        Docker::API::Image.new.remove(image)
    end

    describe ".create" do
        it { expect(described_class.new.create(container).status).to eq(400) }
        it { expect(described_class.new.create("doesn-exist", Cmd: ["ls", "-l"]).status).to eq(404) }
        it do 
            Docker::API::Container.new.pause(container)
            expect(described_class.new.create(container, Cmd: ["ls", "-l"]).status).to eq(409)
        end

        subject do 
            Docker::API::Container.new.unpause(container)
            described_class.new.create(container, Cmd: ["ls", "-l"])         
        end
        it { expect(subject.status).to eq(201) }
        it { expect(subject.json).not_to be(nil) }
        it { expect(subject.json["Id"]).not_to be(nil) }
        
    end
    context "after .create" do 
        subject { described_class.new.create(container, AttachStdout:true, WorkingDir: "/etc", Cmd: ["ls", "-l"]) }
        describe ".start" do
            it { expect(described_class.new.start(subject.json["Id"]).status).to eq(200) }
            it { expect(described_class.new.start(subject.json["Id"]).data[:stream]).not_to be(nil) }
            it { expect(described_class.new.start("doesn-exist").status).to eq(404) }
        end
    
        describe ".resize" do
            #it { expect(described_class.resize(subject.json["Id"], h:100, w:100).status).to eq(201) }
            it { expect(described_class.new.resize(subject.json["Id"]).status).to eq(400) }
            it { expect(described_class.new.resize("doesn-exist", h:100, w:100).status).to eq(404) }
        end
    
        describe ".inspect" do
            it { expect(described_class.new.inspect(subject.json["Id"]).status).to eq(200) }
            it { expect(described_class.new.inspect("doesn-exist").status).to eq(404) }
        end

    end
end