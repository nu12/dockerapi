RSpec.describe Docker::API::Container do
    image =  "nginx:alpine"
    name = "rspec-container"

    before(:all) { Docker::API::Image.create({fromImage: image}) }
    after(:all)  { Docker::API::Image.remove(image) }
    
    describe "::list" do
        it { expect(described_class.list.json).to be_kind_of(Array) }
        it { expect { described_class.list( { invalid: "invalid" } ) }.to raise_error(Docker::API::InvalidParameter) }

        describe "status code" do
            it { expect(described_class.list.status).to eq(200) }
            it { expect(described_class.list( { all: true, limit: 1 } ).status).to eq(200) }
            it { expect(described_class.list( { all: true, size: true } ).status).to eq(200) }
            it { expect(described_class.list( { all: true, filters: {status: ["running", "paused"]} } ).status).to eq(200) }
            it { expect(described_class.list( { all: true, filters: {name: {"#{name}": true}} } ).status).to eq(200) }
            it { expect(described_class.list( { all: true, filters: {exited: {"0": true}} } ).status).to eq(200) }
        end

        describe "request path" do
            it { expect(described_class.list( { all: true, filters: {name: {"#{name}": true}} } ).path).to eq("/containers/json?all=true&filters={\"name\":{\"#{name}\":true}}") }
            it { expect(described_class.list( { all: true, filters: {exited: {"0": true} } } ).path).to eq("/containers/json?all=true&filters={\"exited\":{\"0\":true}}") }
            it { expect(described_class.list( { all: true, filters: {status: ["running"] } } ).path).to eq("/containers/json?all=true&filters={\"status\":[\"running\"]}") }
        end
    end

    describe "::create" do
        context "no name given" do
            subject { described_class.create( {}, { Image: image }) }
            let(:id) { subject.json["Id"] }
            it { expect(subject.status).to eq(201) }
            it { expect(id).not_to be(nil) }
            it { expect(described_class.remove(id).success?).to eq(true) }

        end

        after(:each) { described_class.remove(name) }
        it { expect{described_class.create( {name: name},  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody) }
        it { expect(described_class.create( {name: name},  {Image: image}).status).to eq(201) }
        it do
            response = described_class.create(                    
                 {name: name}, 
                 {
                    Image: image, 
                    HostConfig: {
                        Memory: 6000000,
                        PortBindings: {
                            "80/tcp": [ {HostIp: "0.0.0.0", HostPort: "80"} ]
                        }
                    },
                    Env: ["DOCKER=nice", "DOCKERAPI=awesome"],
                    Cmd: ["echo", "hello from test"],
                    Entrypoint: ["sh"],
                    NetworkingConfig: { 
                        EndpointsConfig: {
                            EndpointSettings: {
                                IPAddress: "192.172.0.100"
                            }
                        }
                    }
                }
            )
            expect(response.status).to eq(201)
        end
    end

    describe "::remove" do
        before(:each) { described_class.create( {name: name},  {Image: image}) }
        after(:all) { described_class.remove(name, {force: true}) }

        it { expect(described_class.remove(name).status).to eq(204) }
        it { expect(described_class.remove("doesn-exist").status).to eq(404) }
        it { expect(described_class.remove(name,  {v: true, link: true}).status).to eq(204) }
        it { expect(described_class.remove(name,  {force: true}).status).to eq(204) }
        it { expect{described_class.remove(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        it do 
            described_class.start(name)
            expect(described_class.remove(name).status).to eq(409)
        end
    end
    
    context "after ::create" do
        before(:all) { described_class.create( {name: name},  {Image: image}) }
        after(:all) { described_class.remove(name, {force: true}) }

        describe "::start" do
            before(:each) { described_class.stop(name) }
            after(:all) { described_class.stop(name) }
            
            it { expect(described_class.start(name).status).to eq(204 )}
            it { expect(described_class.start("doesn-exist").status).to eq(404 )}
            it { expect(described_class.start(name,  {detachKeys: "ctrl-c"}).status).to eq(204 )}
            it { expect(described_class.start(name,  {detachKeys: "ctrl-c"}).path).to eq("/containers/#{name}/start?detachKeys=ctrl-c" )}
            it { expect{described_class.start(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter )}
            it do 
                described_class.start(name)
                expect(described_class.start(name).status).to eq(304)
            end
        end
    
        context "after ::start" do 
            before(:each) { described_class.start(name) }
            after(:all) { described_class.stop(name) }

            describe "::stop" do
                it { expect(described_class.stop(name).status).to be(204) }
                it { expect(described_class.stop("doesn-exist").status).to be(404) }
                it { expect{described_class.stop(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
                it do
                    described_class.stop(name)
                    expect(described_class.stop(name).status).to be(304)
                end
            end

            describe "::kill" do
                it { expect(described_class.kill(name).status).to be(204) }
                it { expect(described_class.kill("doesn-exist").status).to be(404) }
                it { expect(described_class.kill(name,  {signal: "SIGKILL"}).status).to eq(204) }
                it { expect(described_class.kill(name,  {signal: "SIGKILL"}).path).to eq("/containers/#{name}/kill?signal=SIGKILL") }
                it { expect{described_class.kill(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
                it do 
                    described_class.stop(name)
                    expect(described_class.kill(name).status).to be(409)
                end                
            end

            describe "::restart" do
                it { expect(described_class.restart(name).status).to be(204) }
                it { expect(described_class.restart("doesn-exist").status).to be(404) }
                it { expect(described_class.restart(name,  {t: 2}).status).to eq(204) }
                it { expect(described_class.restart(name,  {t: 2}).path).to eq("/containers/#{name}/restart?t=2") }
                it { expect{described_class.restart(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
            end

            describe "::pause" do
                it { expect(described_class.pause(name).status).to be(204) }
                it { expect(described_class.pause("doesn-exist").status).to be(404) }
            end

            describe "::unpause" do
                it { expect(described_class.unpause(name).status).to be(204) }
                it { expect(described_class.unpause("doesn-exist").status).to be(404) }
            end

            describe "::top" do
                it { expect(described_class.top(name).status).to be(200) }
                it { expect(described_class.top(name).json).to be_kind_of(Hash) }
                it { expect(described_class.top("doesn-exist").status).to be(404) }
                it { expect(described_class.top(name,  {ps_args: "aux"} ).status).to be(200) }
                it { expect(described_class.top(name,  {ps_args: "ef"} ).status).to be(200) }
                it { expect{described_class.top(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
            end

            describe "::wait" do
                it do 
                    Thread.new do
                        described_class.stop(name,  {t: 2})
                    end
                    expect(described_class.wait(name).status).to be(200) 
                end
                it do 
                    Thread.new do
                        described_class.stop(name,  {t: 2})
                    end
                    expect(described_class.wait(name).json["StatusCode"]).to be_kind_of(Integer)
                end
            end

            describe "::archive" do
                after(:all) { File.delete(File.expand_path("~/archive.tar")) }
                it { expect(described_class.archive(name, "file").status).to eq(400) }
                it { expect(described_class.archive("doesn-exist", "file").status).to eq(400) }
                it { expect{described_class.archive(name, "file",  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
                
                context "from container to disk" do
                    it { expect(described_class.archive(name, "~/archive.tar", { path: "/usr/share/nginx/html/" }).status).to eq(200) }
                    it { expect{File.open(File.expand_path("~/archive.tar"))}.not_to raise_error }
                    it { expect(described_class.archive(name, "~/wont_exist.tar", { path: "/this-path-doesnt-exist" }).status).to eq(404) }
                    it { expect{File.open(File.expand_path("~/wont_exist.tar"))}.to raise_error(Errno::ENOENT)   }
                end

                context "from disk to container" do
                    it { expect(described_class.archive(name, "~/archive.tar", { path: "/home" }).status).to eq(200) }
                    it { expect(described_class.archive(name, "~/archive.tar", { path: "/this-path-doesnt-exist" }).status).to eq(404) }
                end
            end

            describe "::resize" do
                it { expect(described_class.resize(name).status).to eq(400) }
                it { expect(described_class.resize(name,  {h: 100, w: 100}).status).to eq(200) }
                it { expect(described_class.resize("doesn-exist",  {h: 100, w: 100}).status).to eq(404) }
                it { expect{described_class.resize(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
            end
        end

        describe "::inspect" do
            subject { described_class.inspect(name) }
            it { expect(subject.status).to eq(200) }
            it { expect(subject.body).to match(/\"Name\":\"\/#{name}\"/) }
            it { expect(described_class.inspect("doesn-exist").status).to eq(404) }
            it { expect(described_class.inspect(name,  {size: true}).status).to eq(200) }
            it { expect(described_class.inspect(name,  {size: false}).status).to eq(200) }
            it { expect{described_class.inspect(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe "::logs" do
            it { expect(described_class.logs(name).status).to eq(400) }
            it { expect(described_class.logs(name,  {stdout: false, stderr: false}).status).to eq(400) }
            it { expect(described_class.logs(name,  {stdout: true}).status).to eq(200) }
            it { expect(described_class.logs(name,  {stderr: true}).status).to eq(200) }
            it { expect(described_class.logs(name,  {follow: false, stdout: true, stderr: true}).status).to eq(200) }
            it { expect(described_class.logs(name,  {stdout: true, since: 0}).status).to eq(200) }
            it { expect(described_class.logs(name,  {stdout: true, until: 999999999}).status).to eq(200) }
            it { expect(described_class.logs(name,  {stdout: true, timestamps: true}).status).to eq(200) }
            it { expect(described_class.logs(name,  {stdout: true, tail: "all"}).status).to eq(200) }
            it { expect(described_class.logs("doesn-exist",  {stdout: true, stderr: true}).status).to eq(404) }
            it { expect(described_class.logs("doesn-exist",  {stdout: false, stderr: false}).status).to eq(400) }
            it { expect{described_class.logs(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe "::changes" do
            it { expect(described_class.changes(name).status).to eq(200) }
            it { expect(described_class.changes("doesn-exist").status).to eq(404) }
        end

        describe "::stats" do
            #TODO: implement test to stream response
            it { expect(described_class.stats(name, {stream: false}).status).to eq(200) }
            it { expect(described_class.stats(name, {stream: false}).body).not_to be(nil) }
            it { expect(described_class.stats("doesn-exist", {stream: false}).status).to eq(404) }
            it { expect{described_class.stats(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe "::export" do
            after(:all)  { File.delete(File.expand_path("~/exported_container")) }
            it { expect{File.open(File.expand_path("~/exported_container"))}.to raise_error(Errno::ENOENT) }
            it { expect(described_class.export(name, "~/exported_container").status).to eq(200) }
            it { expect{File.open(File.expand_path("~/exported_container"))}.not_to raise_error }
            it { expect(described_class.export("doesn-exist", "~/wont_exist").status).to eq(404) }
            it { expect{File.open(File.expand_path("~/wont_exist"))}.to raise_error(Errno::ENOENT) }
        end

        describe "::update" do
            it { expect(described_class.update("doesn-exist").status).to eq(404) }
            it { expect{described_class.update(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody)  }
            it do
                expect(described_class.update(name,
                 {
                    Memory: 8000000,
                    CpuShares: 2,
                    RestartPolicy: {
                        Name: "unless-stopped"
                    }
                }
                ).status).to eq(200)
            end   
        end

        describe "::rename" do
            after(:all) { described_class.remove("already-in-use") }
            it { expect(described_class.rename(name).status).to eq(400) }
            it { expect(described_class.rename(name, {name: "#{name}2"}).status).to eq(204) }
            it { expect(described_class.rename("#{name}2",  {name: name}).status).to eq(204) }
            it { expect(described_class.rename("doesn-exist",  {name: "#{name}2"}).status).to eq(404) }
            it { expect{described_class.rename(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
            it do
                described_class.create( {name: "already-in-use"},  {Image: image})
                expect(described_class.rename(name,  {name: "already-in-use"}).status).to eq(409)
            end
        end

        describe "::attach" do
            it { expect(described_class.attach(name).status).to eq(200) }
            it { expect{described_class.attach(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe "::prune" do
            subject { described_class.prune }
            it { expect(subject.status).to eq(200) }
            it { expect(subject.json).to be_kind_of(Hash) }
            it { expect{described_class.prune( {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end
    end
end