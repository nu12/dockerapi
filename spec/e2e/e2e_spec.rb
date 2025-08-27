RSpec.describe "End-to-end test", e2e: true do
    describe "System calls" do 
        system = Docker::API::System.new
        it { expect(system.ping.status).to eq(200) }
        it { expect(system.info.status).to eq(200) }
        it { expect(system.info.success?).to eq(true) }
        it { expect(system.info.json).to be_kind_of(Hash) }
        it { expect(system.info.path).to eq("/v#{Docker::API.default_api_version}/info") }
        it { expect(system.version.status).to eq(200) }
        it { expect(system.version.success?).to eq(true) }
        it { expect(system.version.json).to be_kind_of(Hash) }
        it { expect(system.version.path).to eq("/v#{Docker::API.default_api_version}/version") }
        it { expect(system.df.status).to eq(200) }
        it { expect(system.df.success?).to eq(true) }
        it { expect(system.df.json).to be_kind_of(Hash) }
        it { expect(system.df.path).to eq("/v#{Docker::API.default_api_version}/system/df") }
    end

    describe "Misc of requests that are expected to fail" do
        container = Docker::API::Container.new
        image = Docker::API::Image.new
        it { expect(image.create(fromImage: "doesn-exist:latest").status).to eq(404) } 
        it { expect(image.create(fromSrc: "http://404").status).to eq(500) }
        it { expect(image.details("doesn-exist").status).to eq(404) }
        it { expect(image.tag("doesn-exist", repo: "dockerapi/tag").status).to eq(404) }
        it { expect(image.remove("doesn-exist").status).to eq(404) }
        it { expect(container.create( {platform: "os/no-arch"}, {Image: "image"}).status).to eq(404) }
        it { expect(container.start("doesn-exist").status).to eq(404 )}
        it { expect(container.remove("doesn-exist").status).to eq(404) }
    end

    ["1.40", "1.41", "1.42", "1.43", "1.44", "1.45", "1.46", "1.47", "1.48"].each do | version |
        Docker::API.default_api_version = version
        describe "Basic workflow with version #{version}" do 
            after(:all) do
                Docker::API::Image.new.remove("localhost/dockerapi", force: true)
                Docker::API::Image.new.remove("nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268", force: true)
                File.delete("./html.tar")
            end
            container = Docker::API::Container.new
            image = Docker::API::Image.new
            volume = Docker::API::Volume.new
            it "list images using the specified API version" do expect(image.list.path).to eq("/v#{version}/images/json")  end
            it "download an image" do expect(image.create( fromImage: "nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268" ).status).to be(200)  end
            it "inspect the image" do expect(image.details( "nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268" ).json).to be_kind_of(Hash) end
            it "tag the image" do  expect(image.tag("nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268", repo: "localhost/dockerapi").status).to be(201) end
            it "remove an image" do expect(image.remove("nginx@sha256:94f1c83ea210e0568f87884517b4fe9a39c74b7677e0ad3de72700cfa3da7268").status).to be(200) end
            it "create a volume" do expect(volume.create( Name:"dockerapi" ).status).to be(201) end
            it "create a container" do expect(container.create( {name: "dockerapi1"}, {Image: "localhost/dockerapi", HostConfig: {Binds: ["dockerapi:/usr/share/nginx/html"], PortBindings: {"80/tcp": [ {HostIp: "0.0.0.0", HostPort: "3080"} ]}}}).status).to be(201) end
            it "start container" do expect(container.start("dockerapi1").status).to be(204) end
            it "sleep to wait container" do sleep 2 end
            it "request the container on port 3080" do expect(Excon.get('http://127.0.0.1:3080').body).to match(/Welcome to nginx!/) end
            it "copy content from container" do expect(container.get_archive("dockerapi1", "./html.tar", path: "/usr/share/nginx/html/").status).to be(200) end
            it "verify the content of the copied file" do expect(File.exist?("./html.tar")).to be(true) end
            it "stop container" do expect(container.stop("dockerapi1").status).to be(204) end
            it "wait for the container to stop" do expect(container.wait("dockerapi1").status).to be(200) end
            it "remove container" do expect(container.remove("dockerapi1").status).to be(204) end
            it "remove a volume" do expect(volume.remove("dockerapi").status).to be(204) end
        end
        Docker::API.default_api_version = "1.43"
    end
end
