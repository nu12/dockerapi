RSpec.describe Docker::API::Container do
    image =  "nginx:alpine"
    name = "rspec-container"

    before(:all) { Docker::API::Image.new.create({fromImage: image}) }
    after(:all)  { Docker::API::Image.new.remove(image) }
    
    subject { described_class.new }
    describe ".list" do
        it { expect(subject.list.json).to be_kind_of(Array) }
        it { expect { subject.list( { invalid: "invalid" } ) }.to raise_error(Docker::API::InvalidParameter) }

        describe "status code" do
            it { expect(subject.list.status).to eq(200) }
            it { expect(subject.list( { all: true, limit: 1 } ).status).to eq(200) }
            it { expect(subject.list( { all: true, size: true } ).status).to eq(200) }
            it { expect(subject.list( { all: true, filters: {status: ["running", "paused"]} } ).status).to eq(200) }
            it { expect(subject.list( { all: true, filters: {name: {"#{name}": true}} } ).status).to eq(200) }
            it { expect(subject.list( { all: true, filters: {exited: {"0": true}} } ).status).to eq(200) }
        end

        describe "request path" do
            it { expect(subject.list( { all: true, filters: {name: {"#{name}": true}} } ).path).to eq("/containers/json?all=true&filters={\"name\":{\"#{name}\":true}}") }
            it { expect(subject.list( { all: true, filters: {exited: {"0": true} } } ).path).to eq("/containers/json?all=true&filters={\"exited\":{\"0\":true}}") }
            it { expect(subject.list( { all: true, filters: {status: ["running"] } } ).path).to eq("/containers/json?all=true&filters={\"status\":[\"running\"]}") }
        end
    end

    describe ".create" do
        context "no name given" do
            subject { described_class.new.create( {}, { Image: image }) }
            let(:id) { subject.json["Id"] }
            it { expect(subject.status).to eq(201) }
            it { expect(id).not_to be(nil) }
            it { expect(described_class.new.remove(id).success?).to eq(true) }
            
        end
        context "still no name given" do
            it { expect(subject.create( {platform: "os/no-arch"}, {Image: image}).status).to eq(404) }
        end

        after(:each) { described_class.new.remove(name) }
        it { expect{subject.create( {name: name}, {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody) }
        it { expect{subject.create( {name: name, invalid: "invalid"}, {Image: image})}.to raise_error(Docker::API::InvalidParameter) }
        it { expect(subject.create( {name: name, platform: "linux/amd64"}, {Image: image}).status).to eq(201) }
        it { expect(subject.create( {name: name, platform: "os/no-arch"}, {Image: image}).status).to eq(404) }
        it { expect(subject.create( {name: name}, {Image: image}).status).to eq(201) }
        it do
            response = subject.create(                    
                 {name: name}, 
                 {
                    Image: image, 
                    HostConfig: {
                        #Memory: 6000000,
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

    describe ".remove" do
        before(:each) { subject.create( {name: name},  {Image: image}) }
        after(:all) { described_class.new.remove(name, {force: true}) }

        it { expect(subject.remove(name).status).to eq(204) }
        it { expect(subject.remove("doesn-exist").status).to eq(404) }
        it { expect(subject.remove(name,  {v: true}).status).to eq(204) }
        it { expect(subject.remove(name,  {force: true}).status).to eq(204) }
        it { expect{subject.remove(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        it do 
            subject.start(name)
            expect(subject.remove(name).status).to eq(409)
        end
    end
    
    context "after .create" do
        before(:all) { described_class.new.create( {name: name},  {Image: image}) }
        after(:all) { described_class.new.remove(name, {force: true}) }

        describe ".start" do
            before(:each) { subject.stop(name) }
            after(:all) { described_class.new.stop(name) }
            
            it { expect(subject.start(name).status).to eq(204 )}
            it { expect(subject.start("doesn-exist").status).to eq(404 )}
            it { expect(subject.start(name,  {detachKeys: "ctrl-c"}).status).to eq(204 )}
            it { expect(subject.start(name,  {detachKeys: "ctrl-c"}).path).to eq("/containers/#{name}/start?detachKeys=ctrl-c" )}
            it { expect{subject.start(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter )}
            it do 
                subject.start(name)
                expect(subject.start(name).status).to eq(304)
            end
        end
    
        context "after .start" do 
            before(:each) { subject.start(name) }
            after(:all) { described_class.new.stop(name) }

            describe ".stop" do
                it { expect(subject.stop(name).status).to be(204) }
                it { expect(subject.stop(name, {t: 1}).status).to be(204) }
                it { expect(subject.stop(name, {signal: "SIGINT"}).status).to be(204) }
                it { expect{subject.stop(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
                it { expect(subject.stop("doesn-exist").status).to be(404) }
                it do
                    subject.stop(name)
                    expect(subject.stop(name).status).to be(304)
                end
            end

            describe ".kill" do
                it { expect(subject.kill(name).status).to be(204) }
                it { expect(subject.kill("doesn-exist").status).to be(404) }
                it { expect(subject.kill(name,  {signal: "SIGKILL"}).status).to eq(204) }
                it { expect(subject.kill(name,  {signal: "SIGKILL"}).path).to eq("/containers/#{name}/kill?signal=SIGKILL") }
                it { expect{subject.kill(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
                it do 
                    subject.stop(name)
                    expect(subject.kill(name).status).to be(409)
                end                
            end

            describe ".restart" do
                it { expect(subject.restart(name).status).to be(204) }
                it { expect(subject.restart("doesn-exist").status).to be(404) }
                it { expect(subject.restart(name,  {t: 2}).status).to eq(204) }
                it { expect(subject.restart(name,  {signal: "SIGINT"}).status).to eq(204) }
                it { expect(subject.restart(name,  {t: 2}).path).to eq("/containers/#{name}/restart?t=2") }
                it { expect{subject.restart(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
            end

            describe ".pause" do
                it { expect(subject.pause(name).status).to be(204) }
                it { expect(subject.pause("doesn-exist").status).to be(404) }
            end

            describe ".unpause" do
                it { expect(subject.unpause(name).status).to be(204) }
                it { expect(subject.unpause("doesn-exist").status).to be(404) }
            end

            describe ".top" do
                it { expect(subject.top(name).status).to be(200) }
                it { expect(subject.top(name).json).to be_kind_of(Hash) }
                it { expect(subject.top("doesn-exist").status).to be(404) }
                it { expect(subject.top(name,  {ps_args: "aux"} ).status).to be(200) }
                it { expect(subject.top(name,  {ps_args: "-ef"} ).status).to be(200) }
                it { expect{subject.top(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
            end

            describe ".wait" do
                it do 
                    Thread.new do
                        subject.stop(name,  {t: 2})
                    end
                    expect(subject.wait(name).status).to be(200) 
                end
                it do 
                    Thread.new do
                        subject.stop(name,  {t: 2})
                    end
                    expect(subject.wait(name).json["StatusCode"]).to be_kind_of(Integer)
                end
            end

            context ".archive" do
                after(:all) { File.delete(File.expand_path("~/archive.tar")) }
                it { expect(subject.get_archive(name, "file").status).to eq(400) }
                it { expect(subject.get_archive("doesn-exist", "file").status).to eq(400) }
                it { expect{subject.get_archive(name, "file",  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
                
                describe ".get_archive" do
                    it { expect(subject.get_archive(name, "~/archive.tar", { path: "/usr/share/nginx/html/" }).status).to eq(200) }
                    it { expect{File.open(File.expand_path("~/archive.tar"))}.not_to raise_error }
                    it { expect(subject.get_archive(name, "~/wont_exist.tar", { path: "/this-path-doesnt-exist" }).status).to eq(404) }
                    it { expect{File.open(File.expand_path("~/wont_exist.tar"))}.to raise_error(Errno::ENOENT)   }
                end

                describe ".put_archive" do
                    it { expect(subject.put_archive(name, "~/archive.tar", { path: "/home" }).status).to eq(200) }
                    it { expect(subject.put_archive(name, "~/archive.tar", { path: "/this-path-doesnt-exist" }).status).to eq(404) }
                end
            end

            describe ".resize" do
                it { expect(subject.resize(name).status).to eq(400) }
                it { expect(subject.resize(name,  {h: 100, w: 100}).status).to eq(200) }
                it { expect(subject.resize("doesn-exist",  {h: 100, w: 100}).status).to eq(404) }
                it { expect{subject.resize(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
            end
        end

        describe ".details" do
            it { expect(subject.details(name).status).to eq(200) }
            it { expect(subject.details(name).body).to match(/\"Name\":\"\/#{name}\"/) }
            it { expect(subject.details("doesn-exist").status).to eq(404) }
            it { expect(subject.details(name,  {size: true}).status).to eq(200) }
            it { expect(subject.details(name,  {size: false}).status).to eq(200) }
            it { expect{subject.details(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".logs" do
            it { expect(subject.logs(name).status).to eq(400) }
            it { expect(subject.logs(name,  {stdout: false, stderr: false}).status).to eq(400) }
            it { expect(subject.logs(name,  {stdout: true}).status).to eq(200) }
            it { expect(subject.logs(name,  {stderr: true}).status).to eq(200) }
            it { expect(subject.logs(name,  {follow: false, stdout: true, stderr: true}).status).to eq(200) }
            it { expect(subject.logs(name,  {stdout: true, since: 0}).status).to eq(200) }
            it { expect(subject.logs(name,  {stdout: true, until: 999999999}).status).to eq(200) }
            it { expect(subject.logs(name,  {stdout: true, timestamps: true}).status).to eq(200) }
            it { expect(subject.logs(name,  {stdout: true, tail: "all"}).status).to eq(200) }
            it { expect(subject.logs("doesn-exist",  {stdout: true, stderr: true}).status).to eq(404) }
            it { expect(subject.logs("doesn-exist",  {stdout: false, stderr: false}).status).to eq(400) }
            it { expect{subject.logs(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".changes" do
            it { expect(subject.changes(name).status).to eq(200) }
            it { expect(subject.changes("doesn-exist").status).to eq(404) }
        end

        describe ".stats" do
            #TODO: implement test to stream response
            it { expect(subject.stats(name, {stream: false}).status).to eq(200) }
            it { expect(subject.stats(name, {stream: false}).body).not_to be(nil) }
            it { expect(subject.stats(name, {stream: false, "one-shot": true}).status).to eq(200) }
            it { expect(subject.stats(name, {stream: false, "one-shot": true}).body).not_to be(nil) }
            it { expect(subject.stats("doesn-exist", {stream: false}).status).to eq(404) }
            it { expect{subject.stats(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".export" do
            after(:all)  { File.delete(File.expand_path("~/exported_container")) }
            it { expect{File.open(File.expand_path("~/exported_container"))}.to raise_error(Errno::ENOENT) }
            it { expect(subject.export(name, "~/exported_container").status).to eq(200) }
            it { expect{File.open(File.expand_path("~/exported_container"))}.not_to raise_error }
            it { expect(subject.export("doesn-exist", "~/wont_exist").status).to eq(404) }
            it { expect{File.open(File.expand_path("~/wont_exist"))}.to raise_error(Errno::ENOENT) }
        end

        describe ".update" do
            it { expect(subject.update("doesn-exist").status).to eq(404) }
            it { expect{subject.update(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody)  }
            it do
                expect(subject.update(name,
                 {
                    #Memory: 8000000,
                    #CpuShares: 2,
                    RestartPolicy: {
                        Name: "unless-stopped"
                    }
                }
                ).status).to eq(200)
            end   
        end

        describe ".rename" do
            after(:all) { described_class.new.remove("already-in-use") }
            it { expect(subject.rename(name).status).to eq(400) }
            it { expect(subject.rename(name, {name: "#{name}2"}).status).to eq(204) }
            it { expect(subject.rename("#{name}2",  {name: name}).status).to eq(204) }
            it { expect(subject.rename("doesn-exist",  {name: "#{name}2"}).status).to eq(404) }
            it { expect{subject.rename(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
            it do
                subject.create( {name: "already-in-use"},  {Image: image})
                expect(subject.rename(name,  {name: "already-in-use"}).status).to eq(409)
            end
        end

        describe ".attach" do
            it { expect(subject.attach(name).status).to eq(200) }
            it { expect{subject.attach(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".prune" do
            subject { described_class.new.prune }
            it { expect(subject.status).to eq(200) }
            it { expect(subject.json).to be_kind_of(Hash) }
            it { expect{described_class.new.prune( {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end
    end
end