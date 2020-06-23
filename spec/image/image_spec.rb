RSpec.describe Docker::API::Image do
    image = "busybox:1.31.1-glibc"

    #after(:all) { described_class.prune }
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
    #describe "::list";end
    #describe "::inspect";end
    #describe "::history";end
    #describe "::search";end
    #describe "::tag";end
    #describe "::commit";end
    #describe "::remove";end
    #describe "::prune";end
    #describe "::export(one/several)";end
    #describe "::import";end
    #describe "::push";end
    #describe "::build";end
    #describe "::delete cache";end
    
    
end

