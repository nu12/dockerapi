RSpec.describe Docker::API::Container do
    image =  "nginx:latest"
    name = "rspec-container"

    before(:all) { Docker::API::Image.create({fromImage: image}) }
    after(:all)  { Docker::API::Image.remove(image) }
    
    describe "::list" do
        before(:all) do
            described_class.create( {name: name}, {Image: image})
            described_class.start(name)
        end

        after(:all) do
            described_class.stop(name)
            described_class.remove(name)
        end

        describe "with no params" do
            it "returns status 200" do
                expect(described_class.list.status).to eq(200)
            end
            it "returns an array" do
                expect(JSON.parse(described_class.list.body)).to be_kind_of(Array)
            end
        end

        describe "with valid params" do
            it "returns status 200" do
                expect(described_class.list( { all: true, limit: 1 } ).status).to eq(200)
                expect(described_class.list( { all: true, size: true } ).status).to eq(200)
                expect(described_class.list( { all: true, filters: {status: ["running", "paused"]} } ).status).to eq(200)
                expect(described_class.list( { all: true, filters: {name: {"#{name}": true}} } ).status).to eq(200)
                expect(described_class.list( { all: true, filters: {exited: {"0": true}} } ).status).to eq(200)
            end

            it "requests to correct path" do
                expect(described_class.list( { all: true, filters: {name: {"#{name}": true}} } ).data[:path]).to eq("/containers/json?all=true&filters={\"name\":{\"#{name}\":true}}")
                expect(described_class.list( { all: true, filters: {exited: {"0": true} } } ).data[:path]).to eq("/containers/json?all=true&filters={\"exited\":{\"0\":true}}")
                expect(described_class.list( { all: true, filters: {status: ["running"] } } ).data[:path]).to eq("/containers/json?all=true&filters={\"status\":[\"running\"]}")
            end
        end
        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect { described_class.list( { invalid: "invalid" } ) }.to raise_error(Docker::API::InvalidParameter)
            end
        end
    end

    describe "::create" do
        
        describe "without specified name" do
            it "returns status 201 & container id" do 
                response = described_class.create( {}, { Image: image })
                id = eval(response.body)[:Id] 

                expect(response.status).to eq(201)
                expect(id).not_to be(nil)

                # Manually remove this container
                described_class.remove(id)
            end
        end

        after(:each) { described_class.remove(name) }

        describe "with specified name" do
            it "retuns status 201" do
                expect(described_class.create( {name: name},  {Image: image}).status).to eq(201)
            end
        
            #TODO: test container creation with volume
            describe "with additional configuration" do
                it "retuns status 201" do
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
                it Docker::API::InvalidRequestBody do
                    expect{described_class.create( {name: name},  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody)
                end
            end
        end
    end

    describe "::remove" do
        before(:each) { described_class.create( {name: name},  {Image: image}) }
        after(:all) { described_class.remove(name) }
        
        describe "with no query params" do 
            it "returns status 204" do
                expect(described_class.remove(name).status).to eq(204)
            end

            it "returns status 404" do
                expect(described_class.remove("doesn-exist").status).to eq(404)
            end

            it "returns status 409" do
                described_class.start(name)
                expect(described_class.remove(name).status).to eq(409)
                described_class.stop(name)
                expect(described_class.remove(name).status).to eq(204)
            end
        end

        describe "with valid query params" do 
            it "returns status 204" do
                expect(described_class.remove(name,  {v: true, link: true}).status).to eq(204)
            end

            it "removes running container (returns status 204)" do
                expect(described_class.remove(name,  {force: true}).status).to eq(204)
            end

        end

        describe "with invalid query params" do 
            it Docker::API::InvalidParameter do
                expect{described_class.remove(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) 
            end
        end
    end
    
    context "after ::create" do
        before(:all) { described_class.create( {name: name},  {Image: image}) }
        after(:all) { described_class.remove(name) }

        describe "::start" do
            before(:each) { described_class.stop(name) }
            after(:all) { described_class.stop(name) }
            
            describe "with no query params" do 
                it "returns status 204" do 
                    expect(described_class.start(name).status).to eq(204)
                end
                it "returns status 304" do 
                    described_class.start(name)
                    expect(described_class.start(name).status).to eq(304)
                end
                it "returns status 404" do 
                    expect(described_class.start("doesn-exist").status).to eq(404)
                end
            end

            describe "with valid query_params" do
                it "returns status 204" do 
                    expect(described_class.start(name,  {detachKeys: "ctrl-c"}).status).to eq(204)
                end
                it "requests to correct path" do
                    expect(described_class.start(name,  {detachKeys: "ctrl-c"}).data[:path]).to eq("/containers/#{name}/start?detachKeys=ctrl-c")
                end
            end
    
            describe "with invalid query_params" do
                it Docker::API::InvalidParameter do
                    expect{described_class.start(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)
                end
            end
        end
    
        context "after ::start" do 
            before(:each) { described_class.start(name) }
            after(:all) { described_class.stop(name) }

            describe "::stop" do
                describe  "with no query params" do 
                    it "returns status 204" do
                        expect(described_class.stop(name).status).to be(204)
                    end
                    it "returns status 304" do
                        described_class.stop(name)
                        expect(described_class.stop(name).status).to be(304)
                    end
                    it "returns status 404" do 
                        expect(described_class.stop("doesn-exist").status).to be(404)
                    end
                end
                
                describe "with valid query_params" do
                    it "returns status 204" do
                        expect(described_class.stop(name,  {t: 10}).status).to eq(204)
                        
                    end
                    it "requests to correct path" do
                        expect(described_class.stop(name,  {t: 10}).data[:path]).to eq("/containers/#{name}/stop?t=10")
                    end
                end
        
                describe "with invalid query_params" do
                    it Docker::API::InvalidParameter do
                        expect{described_class.stop(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)
                    end
                end
            end

            describe "::kill" do
                describe  "with no query params" do 
                    it "returns status 204" do
                        expect(described_class.kill(name).status).to be(204)
                    end
                    
                    it "returns status 404" do 
                        expect(described_class.kill("doesn-exist").status).to be(404)
                    end

                    it "returns status 409" do
                        described_class.stop(name)
                        expect(described_class.kill(name).status).to be(409)
                    end
                end
                
                describe "with valid query_params" do
                    it "returns status 204" do
                        expect(described_class.kill(name,  {signal: "SIGKILL"}).status).to eq(204)
                        
                    end
                    it "requests to correct path" do
                        expect(described_class.kill(name,  {signal: "SIGKILL"}).data[:path]).to eq("/containers/#{name}/kill?signal=SIGKILL")
                    end
                end
        
                describe "with invalid query_params" do
                    it Docker::API::InvalidParameter do
                        expect{described_class.kill(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)
                    end
                end
            end

            describe "::restart" do
                describe "with no query params" do 
                    it "returns status 204" do 
                        expect(described_class.restart(name).status).to be(204)
                    end
                    it "returns status 404" do
                        expect(described_class.restart("doesn-exist").status).to be(404)
                    end
                end
                
                describe "with valid query_params" do
                    it "returns status 204" do
                        expect(described_class.restart(name,  {t: 10}).status).to eq(204)
                    end
                    it "requests to correct path" do
                        expect(described_class.restart(name,  {t: 10}).data[:path]).to eq("/containers/#{name}/restart?t=10")
                    end
                end
    
                describe "with invalid query_params" do
                    it Docker::API::InvalidParameter do
                        expect{described_class.restart(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)
                    end
                end
            end

            describe "::pause" do
                it "returns status 204" do 
                    expect(described_class.pause(name).status).to be(204)
                end

                it "returns status 404" do
                    expect(described_class.pause("doesn-exist").status).to be(404)
                end
            end

            describe "::unpause" do
                it "returns status 204" do 
                    expect(described_class.unpause(name).status).to be(204)
                end

                it "returns status 404" do
                    expect(described_class.unpause("doesn-exist").status).to be(404)
                end
            end

            describe "::top" do
                describe "with no query params" do 
                    it "returns status 200" do
                        expect(described_class.top(name).status).to be(200)
                    end

                    it "returns status 404" do
                        expect(described_class.top("doesn-exist").status).to be(404)
                    end
                end

                describe "with valid query params" do 
                    it "returns status 200" do
                        expect(described_class.top(name,  {ps_args: "aux"} ).status).to be(200)
                        expect(described_class.top(name,  {ps_args: "ef"} ).status).to be(200)
                    end
                end
                describe "with invalid query params" do 
                    it Docker::API::InvalidParameter do
                        expect{described_class.top(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)
                    end
                end
            end

            describe "::wait" do
                describe "wait container to stop" do
                    it "returns status 200" do
                        Thread.new do
                            described_class.stop(name,  {t: 2})
                        end
                        expect(described_class.wait(name).status).to be(200)
                    end

                    it "returns container's status code" do
                        Thread.new do
                            described_class.stop(name,  {t: 2})
                        end
                        expect(JSON.parse(described_class.wait(name).body)["StatusCode"]).to be_kind_of(Integer)
                    end
                end
            end

            describe "::archive" do
                describe "with no query params" do
                    it "returns status 400" do 
                        expect(described_class.archive(name, "file").status).to eq(400)
                        expect(described_class.archive("doesn-exist", "file").status).to eq(400)
                    end
                end

                describe "with invalid query params" do
                    it Docker::API::InvalidParameter do 
                        expect{described_class.archive(name, "file",  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)
                    end
                end

                context "from container to disk" do
                    describe "with valid query params" do
                        it "returns status 200" do
                            expect(described_class.archive(name, "~/archive.tar", { path: "/usr/share/nginx/html/" }).status).to eq(200)
                        end

                        it "writes file to disk" do
                            expect{File.open(File.expand_path("~/archive.tar"))}.not_to raise_error
                        end

                        it "returns status 404 & doesn't create a file" do
                            expect(described_class.archive(name, "~/new_archive.tar", { path: "/this-path-doesnt-exist" }).status).to eq(404)
                            expect{File.open(File.expand_path("~/new_archive.tar"))}.to raise_error(Errno::ENOENT)
                        end
                    end
                end

                context "from disk to container" do
                    it "returns status 200" do
                        expect(described_class.archive(name, "~/archive.tar", { path: "/home" }).status).to eq(200)
                    end

                    it "returns status 404" do
                        expect(described_class.archive(name, "~/archive.tar", { path: "/this-path-doesnt-exist" }).status).to eq(404)
                        
                        # Manualy delete file
                        File.delete(File.expand_path("~/archive.tar"))
                    end
                end
            end

            describe "::resize" do
                describe "with no query params" do 
                    it "returns status 400" do
                        expect(described_class.resize(name).status).to eq(400)
                    end
                end
                describe "with valid query params" do 
                    it "returns status 200" do
                        expect(described_class.resize(name,  {h: 100, w: 100}).status).to eq(200)
                    end
                    it "returns status 404" do
                        expect(described_class.resize("doesn-exist",  {h: 100, w: 100}).status).to eq(404)
                    end
                end

                describe "with invalid query params" do 
                    it Docker::API::InvalidParameter do 
                        expect{described_class.resize(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)
                    end
                end
            
            end
        end

        describe "::inspect" do
            describe "with no query_params" do
                let(:res) { described_class.inspect(name) }
                it "returns status 200" do
                    expect(res.status).to eq(200)
                end
                it "returns Name" do
                    expect(res.body).to match(/\"Name\":\"\/#{name}\"/)
                end
                it "returns status 404" do 
                    expect(described_class.inspect("doesn-exist").status).to eq(404)
                end
            end

            describe "with valid query_params" do
                it "returns status 200" do
                    expect(described_class.inspect(name,  {size: true}).status).to eq(200)
                    expect(described_class.inspect(name,  {size: false}).status).to eq(200)
                end
            end

            describe "with invalid query_params" do
                it Docker::API::InvalidParameter do
                    expect{described_class.inspect(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) 
                end
            end
        end

        describe "::logs" do
            describe "with no query params" do 
                it "returns status 400" do 
                    expect(described_class.logs(name).status).to eq(400)
                end
            end
            describe "with valid query params" do 
                it "returns status 200" do 
                    expect(described_class.logs(name,  {stdout: true}).status).to eq(200)
                    expect(described_class.logs(name,  {stderr: true}).status).to eq(200)
                    expect(described_class.logs(name,  {follow: false, stdout: true, stderr: true}).status).to eq(200)
                    expect(described_class.logs(name,  {stdout: true, since: 0}).status).to eq(200)
                    expect(described_class.logs(name,  {stdout: true,until: 999999999}).status).to eq(200)
                    expect(described_class.logs(name,  {stdout: true, timestamps: true}).status).to eq(200)
                    expect(described_class.logs(name,  {stdout: true, tail: "all"}).status).to eq(200)
                end
                it "returns status 404" do 
                    expect(described_class.logs("doesn-exist",  {stdout: true, stderr: true}).status).to eq(404)
                end
            end
            describe "with invalid query params" do 
                it "returns status 400 without stdout/stderr" do 
                    expect(described_class.logs("doesn-exist",  {stdout: false, stderr: false}).status).to eq(400)
                end
                it Docker::API::InvalidParameter do
                    expect{described_class.logs(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) 
                end
            end
        end

        describe "::changes" do
            describe "with no query params" do 
                it "returns status 200" do 
                    expect(described_class.changes(name).status).to eq(200)
                end

                it "returns status 404" do 
                    expect(described_class.changes("doesn-exist").status).to eq(404)
                end
            end
        end

        describe "::stats" do
            describe "no stream" do
                it "returns status 200 & response body" do 
                    expect(described_class.stats(name, {stream: false}).status).to eq(200)
                    expect(described_class.stats(name, {stream: false}).body).not_to be(nil)
                end

                it "returns status 404" do
                    expect(described_class.stats("doesn-exist", {stream: false}).status).to eq(404)
                end
            end

            #TODO: implement test to stream response
            #describe "stream response";do

            describe "with invalid query_params" do
                it Docker::API::InvalidParameter do
                    expect{described_class.stats(name,  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) 
                end
            end
        end

        describe "::export" do
            it Errno::ENOENT do
                expect{File.open(File.expand_path("~/exported_container"))}.to raise_error(Errno::ENOENT)
            end

            it "returns status 200" do
                expect(described_class.export(name, "~/exported_container").status).to eq(200)
            end

            it "saves the exported container" do
                expect{File.open(File.expand_path("~/exported_container"))}.not_to raise_error

                # Manualy delete file
                File.delete(File.expand_path("~/exported_container"))
            end

            it "returns status 404 & doesn't create file" do
                expect(described_class.export("doesn-exist", "~/exported_container2").status).to eq(404)
                expect{File.open(File.expand_path("~/exported_container2"))}.to raise_error(Errno::ENOENT)
            end
        end

        describe "::update" do
            describe "with request body" do
                it "returns status 200" do
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

                it Docker::API::InvalidRequestBody do 
                    expect{described_class.update(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody) 
                end
            end

            it "returns status 404" do
                expect(described_class.update("doesn-exist").status).to eq(404)
            end
        end

        describe "::rename" do
            describe "with no query_params" do
                it "retunrs status 400" do
                    expect(described_class.rename(name).status).to eq(400)
                end
            end

            describe "with valid query_params" do
                it "returns status 204" do 
                    expect(described_class.rename(name, {name: "#{name}2"}).status).to eq(204)
                    expect(described_class.rename("#{name}2",  {name: name}).status).to eq(204)
                end

                it "returns status 404" do 
                    expect(described_class.rename("doesn-exist",  {name: "#{name}2"}).status).to eq(404)
                end

                it "returns status 409" do 
                    described_class.create( {name: "already-in-use"},  {Image: image})
                    expect(described_class.rename(name,  {name: "already-in-use"}).status).to eq(409)
                    described_class.remove("already-in-use")
                end
            end

            describe "with invalid query_params" do
                it Docker::API::InvalidParameter do
                    expect{described_class.rename(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) 
                end
            end
        end

        describe "::attach" do
            describe "no stream" do
                it "returns status 200" do
                    expect(described_class.attach(name).status).to eq(200)
                end
            end

            #TODO: implement test to stream response
            #describe "stream response";do

            describe "with invalid query_params" do
                it Docker::API::InvalidParameter do
                    expect{described_class.attach(name,  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) 
                end
            end 
        end

        describe "::prune" do
            response = described_class.prune
            it "returns status 200" do
                expect(response.status).to eq(200)
            end
            it "returns Hash in the response body" do
                expect(JSON.parse(response.body)).to be_kind_of(Hash)
            end

            describe "with invalid query params" do
                it Docker::API::InvalidParameter do
                    expect{described_class.prune( {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) 
                end
            end
        end
    end
end
