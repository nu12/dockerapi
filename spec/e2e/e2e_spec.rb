RSpec.describe "End-to-end test", e2e: true do
    before(:all) do
        
    end
    after(:all) do
        Docker::API::Image.new.remove("localhost/dockerapi", force: true)
        Docker::API::Image.new.remove("nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268", force: true)
        File.delete("./html.tar")
    end
    config = Docker::API::Config.new
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

    describe "Invalid parameters and invalid bodies" do
        it { expect(config.list(invalid: true, skip_validation: true).status).to be(503) }
        it { expect(config.create(invalid: true, skip_validation: true).status).to be(503) }

        it { expect(container.list({invalid: "invalid", skip_validation: true}).status).to be(200) }
        it { expect(container.remove({invalid: "invalid", platform: "linux/amd64"}, {Image: "nginx", skip_validation: true}).status).to be(400) }
        it { expect(container.create({name: "dockerapi", platform: "linux/amd64"}, {invalid: "invalid", skip_validation: true}).status).to be(400) }

        it { expect(container.start("dockerapi", {invalid: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.stop("dockerapi", {invalid: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.kill("dockerapi", {invalid: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.restart("dockerapi", {invalid: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.top("dockerapi",  {invalid_value: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.resize("dockerapi",  {invalid: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.details("dockerapi",  {invalid_value: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.logs("dockerapi",  {invalid_value: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.stats("dockerapi",  {invalid_value: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.update("dockerapi", {invalid: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.attach("dockerapi",  {invalid: "invalid", skip_validation: true}).status).to be(400) }
        it { expect(container.prune( {invalid: "invalid", skip_validation: true}).status).to be(400) }
    end
    
    describe "Basic workflow" do 
        it "downloads an image" do expect(image.create( fromImage: "nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268" ).status).to be(200)  end
        it "inspects the image" do expect(image.details( "nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268" ).json).to be_kind_of(Hash) end
        it "tags the image" do  expect(image.tag("nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268", repo: "localhost/dockerapi").status).to be(201) end
        it "removes an image" do expect(image.remove("nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268").status).to be(200) end
        it "creates a volume" do expect(volume.create( Name:"dockerapi" ).status).to be(201) end
        it "creates a container" do expect(container.create( {name: "dockerapi1"}, {Image: "localhost/dockerapi", HostConfig: {Binds: ["dockerapi:/usr/share/nginx/html"], PortBindings: {"80/tcp": [ {HostIp: "0.0.0.0", HostPort: "3080"} ]}}}).status).to be(201) end
        it "starts container" do expect(container.start("dockerapi1").status).to be(204) end
        it "sleeps to wait container" do sleep 2 end
        it "requests the container on port 3080" do expect(Excon.get('http://127.0.0.1:3080').body).to match(/Welcome to nginx!/) end
        it "copies content from container" do expect(container.get_archive("dockerapi1", "./html.tar", path: "/usr/share/nginx/html/").status).to be(200) end
        it "verifies the content of the copied file" do expect(File.exist?("./html.tar")).to be(true) end
        it "stops container" do expect(container.stop("dockerapi1").status).to be(204) end
        it "waits for the container to stop" do expect(container.wait("dockerapi1").status).to be(200) end
        it "removes container" do expect(container.remove("dockerapi1").status).to be(204) end
        it "removes a volume" do expect(volume.remove("dockerapi").status).to be(204) end
    end
end
