RSpec.describe Docker::API::Network do

    describe "::list" do 
        describe "with no params" do
            it "returns status 200" do
                expect(described_class.list.status).to eq(200)
            end
        end
        describe "with valid params" do
            it "returns status 200" do
                expect(described_class.list(filters: { dangling: {"true": true} }).status).to eq(200)
                expect(described_class.list(filters: { driver: {"bridge": true} }).status).to eq(200)
                expect(described_class.list(filters: { name: {"bridge": true} }).status).to eq(200)
                expect(described_class.list(filters: { scope: {"local": true} }).status).to eq(200)
                expect(described_class.list(filters: { type: {"custom": true} }).status).to eq(200)
                expect(described_class.list(filters: { type: {"builtin": true} }).status).to eq(200)
            end
        end
        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect{described_class.list( invalid: true )}.to raise_error(Docker::API::InvalidParameter)
            end
        end
    end

    describe "::inspect" do 
        describe "with no params" do
            it "returns status 200" do
                expect(described_class.inspect( "bridge" ).status).to eq(200)
            end

            it "returns status 404" do
                expect(described_class.inspect( "doesn-exist" ).status).to eq(404)
            end
        end
        describe "with valid params" do
            it "returns status 200" do
                expect(described_class.inspect( "bridge", verbose: true ).status).to eq(200)
                expect(described_class.inspect( "bridge", scope: "local" ).status).to eq(200)
            end
        end
        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect{described_class.inspect( "bridge", invalid: true )}.to raise_error(Docker::API::InvalidParameter)
            end
        end
    end

    describe "::create" do 
        describe "with no request body" do
            it "returns status 500" do
                expect(described_class.create.status).to eq(500)
            end
        end
        describe "with valid request body" do
            it "returns status 200" do
                expect(described_class.create( 
                    Name: "rspec-network",
                    CheckDuplicate: true,
                    Driver: "bridge",
                    Internal: true,
                    Attachable: true,
                    EnableIPv6: false
                    ).status).to eq(201)
            end
        end
        describe "with invalid request body" do
            it Docker::API::InvalidRequestBody do
                expect{described_class.create( invalid: true )}.to raise_error(Docker::API::InvalidRequestBody)
            end
        end
    end

    context "having a container to connect" do
        before(:all) do
            Docker::API::Image.create(fromImage: "busybox:1.31.1-uclibc")
            Docker::API::Container.create({name: "rspec-container"}, {Image: "busybox:1.31.1-uclibc"} )
        end
        after(:all) do
            Docker::API::Container.remove("rspec-container")
            Docker::API::Image.remove("busybox:1.31.1-uclibc")
        end
        describe "::connect" do 
            describe "with no request body" do
                it "retuns status 400" do
                    expect(described_class.connect("rspec-network").status).to eq(400)
                end
            end

            describe "with valid request body" do
                it "retuns status 200" do
                    expect(described_class.connect("rspec-network", Container: "rspec-container").status).to eq(200)
                end
            end

            describe "with invalid request body" do
                it Docker::API::InvalidRequestBody do
                    expect{described_class.connect( "rspec-network",  invalid: true )}.to raise_error(Docker::API::InvalidRequestBody)
                end
            end
        end

        describe "::disconnect" do 
            describe "with no request body" do
                it "retuns status 400" do
                    expect(described_class.disconnect("rspec-network").status).to eq(400)
                end
            end

            describe "with valid request body" do
                it "retuns status 200" do
                    described_class.connect("rspec-network", Container: "rspec-container")
                    expect(described_class.disconnect("rspec-network", Container: "rspec-container", Force: true).status).to eq(200)
                end

                it "retuns status 404" do
                    expect(described_class.disconnect("rspec-network", Container: "doesn-exist").status).to eq(404)
                end

                it "retuns status 500" do
                    expect(described_class.disconnect("doesn-exist", Container: "rspec-container").status).to eq(500)
                end
            end

            describe "with invalid request body" do
                it Docker::API::InvalidRequestBody do
                    expect{described_class.disconnect( "rspec-network",  invalid: true )}.to raise_error(Docker::API::InvalidRequestBody)
                end
            end
        end
    end

    describe "::remove" do 
        describe "with no params" do
            it "returns status 204" do
                expect(described_class.remove( "rspec-network" ).status).to eq(204)
            end
            it "returns status 404" do
                expect(described_class.remove( "doesn-exist" ).status).to eq(404)
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
                expect(described_class.prune(filters: { until: {"10m": true} }).status).to eq(200)
                expect(described_class.prune(filters: { until: {"1h30m": true} }).status).to eq(200)
                expect(described_class.prune(filters: { label: {"key=value": true} }).status).to eq(200)
            end
        end
        describe "with invalid params" do
            it Docker::API::InvalidParameter do
                expect{described_class.prune( invalid: true )}.to raise_error(Docker::API::InvalidParameter)
            end
        end
    end
end