require "digest"

RSpec.describe "End-to-end test", e2e: true do
    before(:all) do
        
    end
    after(:all) do
        Docker::API::Image.new.remove("localhost/dockerapi", force: true)
        Docker::API::Image.new.remove("nginx:alpine3.22-slim", force: true)
        File.delete("./html.tar")
    end
    container = Docker::API::Container.new
    image = Docker::API::Image.new
    volume = Docker::API::Volume.new
    system = Docker::API::System.new

    describe "System calls" do 
        it { expect(system.ping.status).to eq(200) }
        it { expect(system.info.status).to eq(200) }
        it { expect(system.info.success?).to eq(true) }
        it { expect(system.info.json).to be_kind_of(Hash) }
        it { expect(system.info.path).to eq("/v#{Docker::API::API_VERSION}/info") }
        it { expect(system.version.status).to eq(200) }
        it { expect(system.version.success?).to eq(true) }
        it { expect(system.version.json).to be_kind_of(Hash) }
        it { expect(system.version.path).to eq("/v#{Docker::API::API_VERSION}/version") }
        it { expect(system.df.status).to eq(200) }
        it { expect(system.df.success?).to eq(true) }
        it { expect(system.df.json).to be_kind_of(Hash) }
        it { expect(system.df.path).to eq("/v#{Docker::API::API_VERSION}/system/df") }
    end

    describe "Misc of requests that are expected to fail" do
        it { expect(image.create(fromImage: "doesn-exist:latest").status).to eq(404) } 
        it { expect(image.create(fromSrc: "http://404").status).to eq(500) }
        it { expect(image.details("doesn-exist").status).to eq(404) }
        it { expect(image.tag("doesn-exist", repo: "dockerapi/tag").status).to eq(404) }
        it { expect(image.remove("doesn-exist").status).to eq(404) }
        it { expect(container.create( {platform: "os/no-arch"}, {Image: "image"}).status).to eq(404) }
        it { expect(container.start("doesn-exist").status).to eq(404 )}
        it { expect(container.remove("doesn-exist").status).to eq(404) }
    end
    
    describe "Basic workflow" do 
        it "downloads an image" do expect(image.create( fromImage: "nginx:alpine" ).status).to be(200)  end
        it "inspects the image" do expect(image.details( "nginx:alpine3.22-slim" ).json).to be_kind_of(Hash) end
        it "tags the image" do  expect(image.tag("nginx:alpine", repo: "localhost/dockerapi").status).to be(201) end
        it "removes an image" do expect(image.remove("nginx:alpine").status).to be(200) end
        it "creates a volume" do expect(volume.create( Name:"dockerapi" ).status).to be(201) end
        it "creates a container" do expect(container.create( {name: "dockerapi1"}, {Image: "localhost/dockerapi", HostConfig: {Binds: ["dockerapi:/usr/share/nginx/html"], PortBindings: {"80/tcp": [ {HostIp: "0.0.0.0", HostPort: "3080"} ]}}}).status).to be(201) end
        it "starts container" do expect(container.start("dockerapi1").status).to be(204) end
        it "requests the container on port 3080" do expect(Excon.get('http://127.0.0.1:3080').body).to match(/Welcome to nginx!/) end
        it "copies content from container" do expect(container.get_archive("dockerapi1", "./html.tar", path: "/usr/share/nginx/html/").status).to be(200) end
        it "verifies the content of the copied file" do expect(Digest::MD5.file("./html.tar").hexdigest).to match(/c3e1d9b10a9f397e745d312505242615/) end
        it "stops container" do expect(container.stop("dockerapi1").status).to be(204) end
        it "waits for the container to stop" do expect(container.wait("dockerapi1").status).to be(200) end
        it "removes container" do expect(container.remove("dockerapi1").status).to be(204) end
        it "removes a volume" do expect(volume.remove("dockerapi").status).to be(204) end
    end
end
