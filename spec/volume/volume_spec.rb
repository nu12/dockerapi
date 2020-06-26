RSpec.describe Docker::API::Volume do
    volume = "rspec-volume"

    describe "::list" do
        describe "with no params" do
            it "returns status 200" do
                expect(described_class.list.status).to eq(200)
            end
        end

        describe "with valid params" do
            it "returns status 200" do
                expect(described_class.list(filters: {dangling: {"true": true}}).status).to eq(200)
                expect(described_class.list(filters: {driver: {"local": true}}).status).to eq(200)
                expect(described_class.list(filters: {name: {"bridge": true}}).status).to eq(200)
            end
        end

        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect{described_class.list( invalid: true )}.to raise_error(Docker::API::InvalidParameter)
            end

            it "returns status 400" do
                expect(described_class.list(filters: {invalid: {"true": true}}).status).to eq(400)
            end
        end
    end

    describe "::create" do
        describe "with no params" do
            response = described_class.create
            it "returns status 201" do
                expect(response.status).to eq(201)
            end
            it "returns volume's id" do
                expect(JSON.parse(response.body)["Name"]).not_to eq(nil)
            end
        end

        describe "with valid params" do
            it "returns status 201" do
                expect(described_class.create(Name: volume, Driver: "local").status).to eq(201)
            end
        end

        describe "with invalid params" do
            it Docker::API::InvalidRequestBody do
                expect{described_class.create( invalid: true )}.to raise_error(Docker::API::InvalidRequestBody)
            end
        end
    end

    describe "::inspect" do
        describe "with no params" do
            it "returns status 200" do
                expect(described_class.inspect(volume).status).to eq(200)
            end

            it "returns status 404" do
                expect(described_class.inspect("doesn-exist").status).to eq(404)
            end
        end
    end

    describe "::remove" do
        describe "with no params" do
            before(:each) { described_class.create(Name: volume, Driver: "local") }
            it "returns status 204" do
                expect(described_class.remove(volume).status).to eq(204)
            end
            it "returns status 404" do
                expect(described_class.remove("doesn-exist").status).to eq(404)
            end
            it "returns status 409" do
                Docker::API::Image.create(fromImage: "busybox:1.31.1-uclibc")
                Docker::API::Container.create({name: "rspec-container"}, {Image: "busybox:1.31.1-uclibc", HostConfig: {Binds: ["#{volume}:/home"]}})
                expect(described_class.remove(volume).status).to eq(409)
            end
        end
        describe "with valid params" do
            after(:all) do
                Docker::API::Container.remove("rspec-container")
                Docker::API::Image.remove("busybox:1.31.1-uclibc")
            end
            it "returns status 409 with force" do
                expect(described_class.remove(volume, force: true).status).to eq(409)
            end
        end
        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect{described_class.remove( volume, invalid: true )}.to raise_error(Docker::API::InvalidParameter)
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
                expect(described_class.prune(filters: {label: {"key": true}}).status).to eq(200)
                expect(described_class.prune(filters: {label: {"key=value": true}}).status).to eq(200)
            end
        end

        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect{described_class.prune( invalid: true )}.to raise_error(Docker::API::InvalidParameter)
            end
        end
    end
end