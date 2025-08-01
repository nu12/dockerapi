RSpec.describe Docker::API::Image do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:distribution) }
    it { is_expected.to respond_to(:history) }
    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:search) }
    it { is_expected.to respond_to(:tag) }
    it { is_expected.to respond_to(:prune) }
    it { is_expected.to respond_to(:remove) }
    it { is_expected.to respond_to(:export) }
    it { is_expected.to respond_to(:import) }
    it { is_expected.to respond_to(:push) }
    it { is_expected.to respond_to(:commit) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:build) }
    it { is_expected.to respond_to(:delete_cache) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".details" do
            it { expect(subject.details("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/dockerapi/json") }
            it { expect(subject.details("dockerapi").request_params[:method]).to eq(:get) }
        end
        describe ".distribution" do
            it { expect(subject.distribution("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/distribution/dockerapi/json") }
            it { expect(subject.distribution("dockerapi", { username: "docker", password: "api" }).request_params[:headers]["X-Registry-Auth"]).to eq("eyJ1c2VybmFtZSI6ImRvY2tlciIsInBhc3N3b3JkIjoiYXBpIn0=") }
            it { expect(subject.distribution("dockerapi").request_params[:method]).to eq(:get) }
        end
        describe ".history" do
            it { expect(subject.history("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/dockerapi/history") }
            it { expect(subject.history("dockerapi").request_params[:method]).to eq(:get) }
        end
        describe ".list" do
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json") }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            
            it { expect(subject.list(all: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?all=true") }
            it { expect(subject.list(all: true, "shared-size": true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?all=true&shared-size=true") }
            it { expect(subject.list(digests: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?digests=true") }
            it { expect(subject.list(all: true, digests: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?all=true&digests=true") }
            it { expect(subject.list(all: true, filters: {dangling: {"true": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?all=true&filters={\"dangling\":{\"true\":true}}") }
            it { expect(subject.list(all: true, filters: {label: {"label-here": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?all=true&filters={\"label\":{\"label-here\":true}}") }
            it { expect(subject.list(all: true, filters: {reference: {"nginx": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?all=true&filters={\"reference\":{\"nginx\":true}}") }
            it { expect(subject.list(all: true, filters: {before: {"nginx": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?all=true&filters={\"before\":{\"nginx\":true}}") }
            it { expect(subject.list(all: true, filters: {since: {"nginx": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/json?all=true&filters={\"since\":{\"nginx\":true}}") }
        end
        describe ".search" do
            it { expect(subject.search.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/search") }
            it { expect(subject.search.request_params[:method]).to eq(:get) }

            it { expect(subject.search(term: "busybox").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/search?term=busybox") }
            it { expect(subject.search(term: "busybox", limit: 2).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/search?term=busybox&limit=2") }
            it { expect(subject.search(term: "busybox", filters: {"is-automated": {"true": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/search?term=busybox&filters={\"is-automated\":{\"true\":true}}") }
            it { expect(subject.search(term: "busybox", filters: {"is-official": {"true": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/search?term=busybox&filters={\"is-official\":{\"true\":true}}") }
            it { expect(subject.search(term: "busybox", filters: {stars: {"20": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/search?term=busybox&filters={\"stars\":{\"20\":true}}") }
            it { expect{subject.search(invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
        end
        describe ".tag" do
            it { expect(subject.tag("dockerapi").request_params[:path]).to eq ("/v#{Docker::API::API_VERSION}/images/dockerapi/tag") }
            it { expect(subject.tag("dockerapi", repo: "dockerapi/tag:1").request_params[:path]).to eq ("/v#{Docker::API::API_VERSION}/images/dockerapi/tag?repo=dockerapi/tag:1") }
            it { expect(subject.tag("dockerapi", repo: "dockerapi/tag", tag: "2").request_params[:path]).to eq ("/v#{Docker::API::API_VERSION}/images/dockerapi/tag?repo=dockerapi/tag&tag=2") }
            it { expect{subject.tag("dockerapi", invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
        end
        describe ".prune" do
            it { expect(subject.prune.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/prune") }
            it { expect(subject.prune.request_params[:method]).to eq(:post) }

            it { expect(subject.prune(filters: {dangling: {"true": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/prune?filters={\"dangling\":{\"true\":true}}") }
            it { expect(subject.prune(filters: {dangling: {"1": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/prune?filters={\"dangling\":{\"1\":true}}") }
            it { expect(subject.prune(filters: {until: {"10m": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/prune?filters={\"until\":{\"10m\":true}}") }
            it { expect(subject.prune(filters: {label: {"LABEL": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/prune?filters={\"label\":{\"LABEL\":true}}") }
            it { expect(subject.prune(filters: {label: {"LABEL": true}, dangling: {"1": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/prune?filters={\"label\":{\"LABEL\":true},\"dangling\":{\"1\":true}}") }
        end
        describe ".remove" do
            it { expect(subject.remove("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/dockerapi") }
            it { expect(subject.remove("dockerapi").request_params[:method]).to eq(:delete) }
            it { expect(subject.remove("dockerapi", force: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/dockerapi?force=true") }
            it { expect(subject.remove("dockerapi", noprune: false).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/dockerapi?noprune=false") }
            it { expect{subject.remove("dockerapi", invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.remove("dockerapi", invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
        end
        describe ".export" do
            before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :port => 2375 }, { headers: {'Content-Type': 'text'}, body: 'a', status: 200 }) }
            after(:all) do
                Excon.unstub({ :method => :get })
                File.delete(File.expand_path("~/exported_image.tar"))
            end
            it { expect{File.open(File.expand_path("~/exported_image.tar"))}.to raise_error(Errno::ENOENT) }
            it { expect(subject.export("dockerapi", "~/exported_image.tar").status).to eq(200) }
            it { expect{File.open(File.expand_path("~/exported_image.tar"))}.not_to raise_error }
        end
        describe ".import" do
            before(:all) do
                Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :post, :port => 2375 }, { status: 200 })
                File.write("import.tar", "\u0000")
            end
            after(:all) do
                Excon.unstub({ :method => :post })
                File.delete(File.expand_path("import.tar"))
            end

            it { expect(subject.import("import.tar").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/load") }
            it { expect(subject.import("import.tar", quiet: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/load?quiet=true") }
            it { expect(subject.import("import.tar", quiet: true).request_params[:method]).to eq(:post) }
            it { expect(subject.import("import.tar", quiet: true).request_params[:headers]["Content-Type"]).to eq("application/x-tar") }
            it { expect{subject.import("import.tar", invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
        end
        describe ".push" do
            it { expect(subject.push("localhost:5000/dockerapi", {},{username: "janedoe", password: "password"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/localhost:5000/dockerapi/push") }
            it { expect(subject.push("localhost:5000/dockerapi", {},{username: "janedoe", password: "password"}).request_params[:method]).to eq(:post) }
            it { expect(subject.push("localhost:5000/dockerapi", {},{username: "janedoe", password: "password"}).request_params[:headers]["X-Registry-Auth"]).to eq("eyJ1c2VybmFtZSI6ImphbmVkb2UiLCJwYXNzd29yZCI6InBhc3N3b3JkIn0=") }
            it { expect{subject.push("localhost:5000/push:1", invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.push("localhost:5000/push:1")}.to raise_error(Docker::API::Error, "Provide authentication parameters to push an image") }
        end
        describe ".commit" do
            before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :port => 2375 }, { headers: {'Content-Type': 'application/json'}, body: '{"Config": {}}', status: 200 }) }
            after(:all) { Excon.unstub({ :method => :get }) }
            it { expect(subject.commit(container: "dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/commit?container=dockerapi") }
            it { expect(subject.commit(container: "dockerapi").request_params[:method]).to eq(:post) }
            it { expect(subject.commit(container: "dockerapi").request_params[:body]).to eq("{}") }

            it { expect(subject.commit(container: "dockerapi", repo: "dockerapi/dockerapi:1" ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/commit?container=dockerapi&repo=dockerapi/dockerapi:1") }
            it { expect(subject.commit(container: "dockerapi", repo: "dockerapi/dockerapi", tag: "2" ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/commit?container=dockerapi&repo=dockerapi/dockerapi&tag=2") }
            it { expect(subject.commit(container: "dockerapi", repo: "dockerapi/dockerapi", tag: "3", comment: "Comment from commit" ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/commit?container=dockerapi&repo=dockerapi/dockerapi&tag=3&comment=Commentfromcommit") }
            it { expect(subject.commit(container: "dockerapi", repo: "dockerapi/dockerapi", tag: "4", author: "dockerapi" ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/commit?container=dockerapi&repo=dockerapi/dockerapi&tag=4&author=dockerapi") }
            it { expect(subject.commit(container: "dockerapi", repo: "dockerapi/dockerapi", tag: "5", pause: false ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/commit?container=dockerapi&repo=dockerapi/dockerapi&tag=5&pause=false") }
            it { expect(subject.commit({container: "dockerapi", repo: "dockerapi/dockerapi:6"}, {OpenStdin: false, Cmd: "echo dockerapi", Entrypoint: [""]} ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/commit?container=dockerapi&repo=dockerapi/dockerapi:6") }
            it { expect(subject.commit({container: "dockerapi", repo: "dockerapi/dockerapi:6"}, {OpenStdin: false, Cmd: "echo dockerapi", Entrypoint: [""]} ).request_params[:body]).to eq("{\"OpenStdin\":false,\"Cmd\":\"echo dockerapi\",\"Entrypoint\":[\"\"]}") }
            it { expect{subject.commit(invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.commit({invalid: "invalid"}, {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.commit({}, {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody) }
        end
        describe ".create" do
            context "from repository without authentication" do
                it { expect(subject.create(fromImage: "nginx").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/create?fromImage=nginx") }
                it { expect(subject.create(fromImage: "nginx").request_params[:method]).to eq(:post) }
            end
            context "from local tar file" do
                before(:all) { File.write("create.tar", "\u0000") }
                after(:all) { File.delete(File.expand_path("create.tar")) }
                it { expect(subject.create(fromSrc: "create.tar").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/create?fromSrc=-") }
                it { expect(subject.create(fromSrc: "create.tar", repo: "dockerapi", message: "Imported with dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/create?fromSrc=-&repo=dockerapi&message=Importedwithdockerapi") }
            end
            context "from remote tar file" do
                let(:url) { "https://address/to/image.tar" }
                it { expect(subject.create(fromSrc: url).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/create?fromSrc=https://address/to/image.tar") }
                it { expect(subject.create(fromSrc: url, repo: "dockerapi", message: "Imported with dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/images/create?fromSrc=https://address/to/image.tar&repo=dockerapi&message=Importedwithdockerapi") }
            end
        end
        describe ".build" do
            before(:all) { File.write("build.tar.xz", "\u0000") }
            after(:all) { File.delete(File.expand_path("build.tar.xz")) }

            it { expect(subject.build("build.tar.xz").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build") }
            it { expect(subject.build("build.tar.xz").request_params[:method]).to eq(:post) }
            it { expect(subject.build("build.tar.xz").request_params[:headers]["Content-type"]).to eq("application/x-tar") }
            it { expect(subject.build("build.tar.xz", q: true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build?q=true") }
            it { expect(subject.build("build.tar.xz", q: true, rm: false).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build?q=true&rm=false") }
            it { expect(subject.build("build.tar.xz", memory: 4000000, rm: true, forcerm:true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build?memory=4000000&rm=true&forcerm=true") }
            it { expect(subject.build("build.tar.xz", memory: 4000000, rm: true, forcerm:true, pull:true).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build?memory=4000000&rm=true&forcerm=true&pull=true") }
            it { expect(subject.build(nil, remote: "https://address/to/image.tar.xz").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build?remote=https://address/to/image.tar.xz") }
            it { expect(subject.build(nil, remote: "https://address/to/Dockerfile").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build?remote=https://address/to/Dockerfile") }

            it { expect{subject.build("build.tar.xz", invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.build(nil, remote: "https://address/to/image.tar.xz", invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.build(nil, invalid: "invalid", skip_validation: true)}.to raise_error(Docker::API::Error) }
        end
        describe ".delete_cache" do
            it { expect(subject.delete_cache.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build/prune") }
            it { expect(subject.delete_cache.request_params[:method]).to eq(:post) }
            it { expect(subject.delete_cache(all:true, "keep-storage": 100000, filters: {until: {"24h": true}, inuse: {"true": true}, shared: {"true": true}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/build/prune?all=true&keep-storage=100000&filters={\"until\":{\"24h\":true},\"inuse\":{\"true\":true},\"shared\":{\"true\":true}}") }
            it { expect{subject.delete_cache(invalid: "invalid")}.to raise_error(Docker::API::InvalidParameter) }
        end
    end
end