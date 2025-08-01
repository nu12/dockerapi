RSpec.describe Docker::API::Service do
    subject { described_class.new }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:delete) }
    it { is_expected.to respond_to(:update) }
    it { is_expected.to respond_to(:logs) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }
    
        describe ".list" do
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services") }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            it { expect(subject.list(status:true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services?status=true") }
            it { expect(subject.list(filters: {id: ["9mnpnzenvg8p8tdbtq4wvbkcz"]}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services?filters={\"id\":[\"9mnpnzenvg8p8tdbtq4wvbkcz\"]}") }
            it { expect(subject.list(filters: {label: ["key=value"]}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services?filters={\"label\":[\"key=value\"]}") }
            it { expect(subject.list(filters: {mode: ["replicated", "global"]}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services?filters={\"mode\":[\"replicated\",\"global\"]}") }
            it { expect(subject.list(filters: {name: ["service-name"]}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services?filters={\"name\":[\"service-name\"]}") }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".create" do
            it { expect(subject.create({Name: "dockerapi", TaskTemplate: {ContainerSpec: { Image: "busybox:1.31.1-uclibc" }},Mode: { Replicated: { Replicas: 2 } },EndpointSpec: { Ports: [{Protocol: "tcp", PublishedPort: 8080, TargetPort: 80}] }}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/create") }
            it { expect(subject.create({Name: "dockerapi", TaskTemplate: {ContainerSpec: { Image: "busybox:1.31.1-uclibc" }},Mode: { Replicated: { Replicas: 2 } },EndpointSpec: { Ports: [{Protocol: "tcp", PublishedPort: 8080, TargetPort: 80}] }}).request_params[:method]).to eq(:post) }
            it { expect(subject.create({Name: "dockerapi", TaskTemplate: {ContainerSpec: { Image: "busybox:1.31.1-uclibc" }},Mode: { Replicated: { Replicas: 2 } },EndpointSpec: { Ports: [{Protocol: "tcp", PublishedPort: 8080, TargetPort: 80}] }}).request_params[:body]).to eq("{\"Name\":\"dockerapi\",\"TaskTemplate\":{\"ContainerSpec\":{\"Image\":\"busybox:1.31.1-uclibc\"}},\"Mode\":{\"Replicated\":{\"Replicas\":2}},\"EndpointSpec\":{\"Ports\":[{\"Protocol\":\"tcp\",\"PublishedPort\":8080,\"TargetPort\":80}]}}") }
            it { expect(subject.create({Name: "dockerapi", TaskTemplate: {ContainerSpec: { Image: "busybox:1.31.1-uclibc" }},Mode: { Replicated: { Replicas: 2 } },EndpointSpec: { Ports: [{Protocol: "tcp", PublishedPort: 8080, TargetPort: 80}] }}).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect(subject.create({Name: "dockerapi", TaskTemplate: {ContainerSpec: { Image: "busybox:1.31.1-uclibc" }},Mode: { Replicated: { Replicas: 2 } },EndpointSpec: { Ports: [{Protocol: "tcp", PublishedPort: 8080, TargetPort: 80}] }}, {username: "janedoe", password: "password"}).request_params[:headers]["X-Registry-Auth"]).to eq("eyJ1c2VybmFtZSI6ImphbmVkb2UiLCJwYXNzd29yZCI6InBhc3N3b3JkIn0=") }
            it { expect{subject.create({ invalid: true })}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".details" do
            it { expect(subject.details( "dockerapi" ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi") }
            it { expect(subject.details( "dockerapi" ).request_params[:method]).to eq(:get) }
            it { expect(subject.details( "dockerapi", insertDefaults: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi?insertDefaults=true") }
            it { expect{subject.details( "dockerapi", invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".logs" do
            it { expect(subject.logs( "dockerapi", details: true, stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi/logs?details=true&stdout=true") }
            it { expect(subject.logs( "dockerapi", details: true, stdout: true ).request_params[:method]).to eq(:get) }
            it { expect(subject.logs( "dockerapi", details: true, stderr: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi/logs?details=true&stderr=true") }
            it { expect(subject.logs( "dockerapi", since: 0, stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi/logs?since=0&stdout=true") }
            it { expect(subject.logs( "dockerapi", timestamps: 0, stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi/logs?timestamps=0&stdout=true") }
            it { expect(subject.logs( "dockerapi", tail: 10, stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi/logs?tail=10&stdout=true") }
            it { expect(subject.logs( "dockerapi", tail: "all", stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi/logs?tail=all&stdout=true") }
            it { expect{subject.details( "dockerapi", invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".update" do
            it { expect(subject.update("dockerapi", {version: "version"}, {}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi/update?version=version") }
            it { expect(subject.update("dockerapi", {version: "version"}, {}).request_params[:method]).to eq(:post) }
            it { expect(subject.update("dockerapi", {version: "version"}, {}).request_params[:headers]["Content-Type"]).to eq("application/json") }
            it { expect(subject.update("dockerapi", {version: "version"}, {}, {username: "janedoe", password: "password"}).request_params[:headers]["X-Registry-Auth"]).to eq("eyJ1c2VybmFtZSI6ImphbmVkb2UiLCJwYXNzd29yZCI6InBhc3N3b3JkIn0=") }
            it { expect(subject.update("dockerapi", {version: "version"}, {}.merge!({TaskTemplate: {RestartPolicy: { Condition: "any", MaxAttempts: 2 }}, Mode: { Replicated: { Replicas: 1 } }})).request_params[:body]).to eq("{\"TaskTemplate\":{\"RestartPolicy\":{\"Condition\":\"any\",\"MaxAttempts\":2}},\"Mode\":{\"Replicated\":{\"Replicas\":1}}}") }
            it { expect{subject.update("dockerapi", {version: "version", invalid: true })}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.update("dockerapi", {version: "version"}, { invalid: true })}.to raise_error(Docker::API::InvalidRequestBody) }
        end

        describe ".delete" do
            it { expect(subject.delete("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/services/dockerapi") }
            it { expect(subject.delete("dockerapi").request_params[:method]).to eq(:delete) }
        end
        
    end
end