RSpec.describe Docker::API::Image do
    image = "busybox:1.31.1-glibc"

    after(:all) { described_class.prune(filters: {dangling: {"false": true}}) }
    describe "::create" do
        
        it Docker::API::InvalidParameter do
            expect{described_class.create(invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter)
        end

        context "without authentication" do
            describe "pulls from repository" do
                after(:each) { described_class.remove(image) }
                it "returns status 200" do
                    expect(described_class.create(fromImage: image).status).to eq(200)
                end
    
                it "returns status 404" do
                    expect(described_class.create(fromImage: "doesn-exist").status).to eq(404)
                end
            end
            
            describe "imports image from tar file" do
                let(:path) { "resources/busybox.tar" }
                it "returns status 200" do 
                    expect(described_class.create(fromSrc: path).status).to eq(200)
                    expect(described_class.create(fromSrc: path, repo: "dockerapi/busybox:tar1").status).to eq(200)
                    expect(described_class.create(fromSrc: path, repo: "dockerapi/busybox", tag: "tar2").status).to eq(200)
                    expect(described_class.create(fromSrc: path, repo: "dockerapi/busybox:tar3", message: "Imported with dockerapi").status).to eq(200)
                end
            end
    
            describe "imports tar image from URL" do
                let(:url) { "https://github.com/nu12/dockerapi/blob/master/resources/busybox.tar?raw=true" }
                it "returns status 200" do 
                    expect(described_class.create(fromSrc: url).status).to eq(200)
                    expect(described_class.create(fromSrc: url, repo: "dockerapi/busybox:url1").status).to eq(200)
                    expect(described_class.create(fromSrc: url, repo: "dockerapi/busybox", tag: "url2").status).to eq(200)
                    expect(described_class.create(fromSrc: url, repo: "dockerapi/busybox:url3", message: "Imported with dockerapi").status).to eq(200)
                end
                it "returns status 500" do 
                    expect(described_class.create(fromSrc: "http://404").status).to eq(500)
                end
            end

        end

        context "with authentication" do
            describe "with valid credentials" do
                describe "pulls from repository" do
                    after(:each) { described_class.remove(image) }
                    it "returns status 200" do
                        expect(described_class.create({fromImage: image}, {username: ENV['DOCKER_USERNAME'], password: ENV['DOCKER_PASSWORD']}).status).to eq(200)
                    end
        
                    it "returns status 404" do
                        expect(described_class.create({fromImage: "doesn-exist"}, {username: ENV['DOCKER_USERNAME'], password: ENV['DOCKER_PASSWORD']}).status).to eq(404)
                    end
                end
            end

            describe "with invalid credentials" do
                describe "pulls from repository" do
                    it "returns status 401" do
                        #expect(described_class.create({fromImage: image}, {username: "incorrect", password: "incorrect"}).status).to eq(401)
                    end
                end
            end
        end
    end

    context "after ::create" do 
        before(:all) { described_class.create(fromImage: image) }
        after(:all) { described_class.prune(filters: {dangling: {"false": true}}) }

        describe "::list" do
            describe "with no params" do
                it "returns status 200" do
                    expect(described_class.list.status).to eq(200)
                end
            end
    
            describe "with valid params" do
                it "returns status 200" do
                    expect(described_class.list(all: true).status).to eq(200)
                    expect(described_class.list(digests: true).status).to eq(200)
                    expect(described_class.list(all: true, digests: true).status).to eq(200)
                    expect(described_class.list(all: true, filters: {dangling: {"true": true}}).status).to eq(200)
                    expect(described_class.list(all: true, filters: {label: {"label-here": true}}).status).to eq(200)
                    expect(described_class.list(all: true, filters: {reference: {"#{image}": true}}).status).to eq(200)
                    expect(described_class.list(all: true, filters: {before: {"#{image}": true}}).status).to eq(200)
                    expect(described_class.list(all: true, filters: {since: {"#{image}": true}}).status).to eq(200)
                end
    
                it "requests to correct path" do 
                    expect(described_class.list(all: true).data[:path]).to eq("/images/json?all=true")
                    expect(described_class.list(digests: true).data[:path]).to eq("/images/json?digests=true")
                    expect(described_class.list(all: true, digests: true).data[:path]).to eq("/images/json?all=true&digests=true")
                    expect(described_class.list(all: true, filters: {dangling: {"true": true}}).data[:path]).to eq("/images/json?all=true&filters={\"dangling\":{\"true\":true}}")
                    expect(described_class.list(all: true, filters: {label: {"label-here": true}}).data[:path]).to eq("/images/json?all=true&filters={\"label\":{\"label-here\":true}}")
                    expect(described_class.list(all: true, filters: {reference: {"#{image}": true}}).data[:path]).to eq("/images/json?all=true&filters={\"reference\":{\"#{image}\":true}}")
                    expect(described_class.list(all: true, filters: {before: {"#{image}": true}}).data[:path]).to eq("/images/json?all=true&filters={\"before\":{\"#{image}\":true}}")
                    expect(described_class.list(all: true, filters: {since: {"#{image}": true}}).data[:path]).to eq("/images/json?all=true&filters={\"since\":{\"#{image}\":true}}")
                end
            end
    
            describe "with invalid params" do
                it Docker::API::InvalidParameter do
                    expect{described_class.list(invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter)
                end
            end
        
        end

        describe "::inspect" do
            it "returns status 200" do
                expect(described_class.inspect(image).status).to eq(200)
            end
            it "returns status 404" do
                expect(described_class.inspect("doesn-exist").status).to eq(404)
            end
        end
        describe "::history" do
            it "returns status 200" do
                expect(described_class.history(image).status).to eq(200)
            end
            it "returns status 404" do
                expect(described_class.history("doesn-exist").status).to eq(404)
            end
        end
        describe "::tag" do
            describe "with no params" do
                it "returns status 500" do
                    expect(described_class.tag(image).status).to eq(500)
                end
            end

            describe "with valid params" do
                it "returns status 201" do
                    expect(described_class.tag(image, repo: "dockerapi/tag:1").status).to eq(201)
                    expect(described_class.tag(image, repo: "dockerapi/tag", tag: "2").status).to eq(201)
                end

                it "returns status 404" do
                    expect(described_class.tag("doesn-exist", repo: "dockerapi/tag").status).to eq(404)
                end
            end
            describe "with invalid params" do
                it Docker::API::InvalidParameter do
                    expect{described_class.tag(image, invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter)
                end
            end
        
        end
        #describe "::push";end
        #describe "::export(one/several)";end
        #describe "::import";end
    end
    
    
    #describe "::search";end
    #describe "::commit";end
    describe "::remove" do
        before(:each) { described_class.create(fromImage: image) }
        after(:all) { Docker::API::Container.prune }
        
        describe "with no params" do
            after(:all) do 
                Docker::API::Container.prune
                described_class.prune
            end
            it "returns status 200" do
                expect(described_class.remove(image).status).to eq(200)
            end

            it "returns status 404" do
                expect(described_class.remove("doesn-exist").status).to eq(404)
            end

            it "returns status 409" do
                Docker::API::Container.create( {}, { Image: image })
                expect(described_class.remove(image).status).to eq(409)
            end
        end

        describe "with valid params" do
            it "returns status 200" do
                expect(described_class.remove(image, noprune: false).status).to eq(200)
            end

            it "returns status 404" do
                expect(described_class.remove("doesn-exist", noprune: true).status).to eq(404)

            end

            it "returns status 409" do
                Docker::API::Container.create( {}, { Image: image })
                expect(described_class.remove(image).status).to eq(409)
            end
            it "returns status 200 with force" do
                expect(described_class.remove(image, force: true).status).to eq(200)
            end
        end

        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect{described_class.remove(image, invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter)
                expect{described_class.remove("doesn-exist", invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter)
            end
        end
    end
    describe "::prune" do        
        describe "with no params" do
            it "returns status 200" do
                expect(described_class.prune.status).to eq(200)
            end
        end

        describe "with valid params" do
            it "returns status 200" do
                expect(described_class.prune(filters: {dangling: {"true": true}}).status).to eq(200)
                expect(described_class.prune(filters: {dangling: {"1": true}}).status).to eq(200)
                expect(described_class.prune(filters: {dangling: {"false": true}}).status).to eq(200)
                expect(described_class.prune(filters: {until: {"10m": true}}).status).to eq(200)
                expect(described_class.prune(filters: {label: {"LABEL": true}}).status).to eq(200)
                expect(described_class.prune(filters: {label: {"LABEL": true}, dangling: {"1": true}}).status).to eq(200)
            end

            it "requests to correct path" do 
                expect(described_class.prune(filters: {dangling: {"true": true}}).data[:path]).to eq("/images/prune?filters={\"dangling\":{\"true\":true}}")
                expect(described_class.prune(filters: {dangling: {"1": true}}).data[:path]).to eq("/images/prune?filters={\"dangling\":{\"1\":true}}")
                expect(described_class.prune(filters: {until: {"10m": true}}).data[:path]).to eq("/images/prune?filters={\"until\":{\"10m\":true}}")
                expect(described_class.prune(filters: {label: {"LABEL": true}}).data[:path]).to eq("/images/prune?filters={\"label\":{\"LABEL\":true}}")
                expect(described_class.prune(filters: {label: {"LABEL": true}, dangling: {"1": true}}).data[:path]).to eq("/images/prune?filters={\"label\":{\"LABEL\":true},\"dangling\":{\"1\":true}}")
            end
        end

        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect{described_class.prune( invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter)
            end
        end
    
    end
    #describe "::build";end
    #describe "::delete cache";end
    
end

