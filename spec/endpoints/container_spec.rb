RSpec.describe Docker::API::Container do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:top) }
    it { is_expected.to respond_to(:changes) }
    it { is_expected.to respond_to(:start) }
    it { is_expected.to respond_to(:stop) }
    it { is_expected.to respond_to(:restart) }
    it { is_expected.to respond_to(:kill) }
    it { is_expected.to respond_to(:wait) }
    it { is_expected.to respond_to(:update) }
    it { is_expected.to respond_to(:rename) }
    it { is_expected.to respond_to(:resize) }
    it { is_expected.to respond_to(:prune) }
    it { is_expected.to respond_to(:pause) }
    it { is_expected.to respond_to(:unpause) }
    it { is_expected.to respond_to(:remove) }
    it { is_expected.to respond_to(:logs) }
    it { is_expected.to respond_to(:attach) }
    it { is_expected.to respond_to(:export) }
    it { is_expected.to respond_to(:get_archive) }
    it { is_expected.to respond_to(:put_archive) }

    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".list" do
            before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :port => 2375 }, {headers: {'Content-Type': 'application/json'}, body: '[]', status: 200 })  }
            after(:all) { Excon.unstub({ :method => :get }) }
            it { expect(subject.list.json).to be_kind_of(Array) }
            it { expect(subject.list( { all: true, filters: {name: {"test": true}} } ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/json?all=true&filters={\"name\":{\"test\":true}}") }
            it { expect(subject.list( { all: true, filters: {exited: {"0": true} } } ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/json?all=true&filters={\"exited\":{\"0\":true}}") }
            it { expect(subject.list( { all: true, filters: {status: ["running"] } } ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/json?all=true&filters={\"status\":[\"running\"]}") }
            it { expect { subject.list( { invalid: "invalid" } ) }.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".create" do
            it { expect(subject.create({name: "dockerapi", platform: "linux/amd64"}, {Image: "nginx"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/create?name=dockerapi&platform=linux/amd64") }
            it { expect(subject.create({name: "dockerapi", platform: "linux/amd64"}, {Image: "nginx"}).request_params[:method]).to eq(:post) }
            it { expect(subject.create({name: "dockerapi", platform: "linux/amd64"}, {Image: "nginx"}).request_params[:body]).to eq('{"Image":"nginx"}') }
            it { expect{subject.remove({invalid: "invalid", platform: "linux/amd64"}, {Image: "nginx"})}.to raise_error(Docker::API::InvalidParameter)  }
            it { expect{subject.create({name: "dockerapi", platform: "linux/amd64"}, {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody)  }
        end

        describe ".remove" do
            it { expect(subject.remove("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi") }
            it { expect(subject.remove("dockerapi").request_params[:method]).to eq(:delete) }
            it { expect(subject.remove("dockerapi", {v: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi?v=true") }
            it { expect(subject.remove("dockerapi", {force: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi?force=true") }
            it { expect{subject.remove("dockerapi",  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".start" do
            it { expect(subject.start("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/start") }
            it { expect(subject.start("dockerapi", {detachKeys: "ctrl-c"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/start?detachKeys=ctrl-c") }
            it { expect(subject.start("dockerapi").request_params[:method]).to eq(:post) }
            it { expect{subject.start("dockerapi", {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".stop" do
            it { expect(subject.stop("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/stop") }
            it { expect(subject.stop("dockerapi", {signal: "SIGINT"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/stop?signal=SIGINT") }
            it { expect(subject.stop("dockerapi").request_params[:method]).to eq(:post) }
            it { expect{subject.stop("dockerapi", {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".kill" do
            it { expect(subject.kill("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/kill") }
            it { expect(subject.kill("dockerapi", {signal: "SIGINT"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/kill?signal=SIGINT") }
            it { expect(subject.kill("dockerapi").request_params[:method]).to eq(:post) }
            it { expect{subject.kill("dockerapi", {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".restart" do
            it { expect(subject.restart("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/restart") }
            it { expect(subject.restart("dockerapi", {signal: "SIGINT"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/restart?signal=SIGINT") }
            it { expect(subject.restart("dockerapi").request_params[:method]).to eq(:post) }
            it { expect{subject.restart("dockerapi", {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".pause" do
            it { expect(subject.pause("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/pause") }
        end

        describe ".unpause" do
            it { expect(subject.unpause("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/unpause") }
        end

        describe ".top" do
            before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :port => 2375 }, { headers: {'Content-Type': 'application/json'}, body: '{}', status: 200 }) }
            after(:all) { Excon.unstub({ :method => :get }) }

            it { expect(subject.top("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/top") }
            it { expect(subject.top("dockerapi").request_params[:method]).to eq(:get) }
            it { expect(subject.top("dockerapi").json).to be_kind_of(Hash) }            
            it { expect{subject.top("dockerapi",  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".wait" do
            it { expect(subject.wait("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/wait") }
            it { expect(subject.wait("dockerapi").request_params[:method]).to eq(:post) }
        end

        describe ".get_archive" do
            it { expect(subject.get_archive("dockerapi", "~/archive.tar", { path: "/usr/share/nginx/html/" }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/archive?path=/usr/share/nginx/html/") }
            it { expect(subject.get_archive("dockerapi", "~/archive.tar", { path: "/usr/share/nginx/html/" }).request_params[:method]).to eq(:get) }
        end

        describe ".put_archive" do
            it { expect(subject.put_archive("dockerapi", "~/archive.tar", { path: "/home" }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/archive?path=/home") }
            it { expect(subject.put_archive("dockerapi", "~/archive.tar", { path: "/home" }).request_params[:method]).to eq(:put) }
        end

        describe ".resize" do
            it { expect(subject.resize("dockerapi",  {h: 100, w: 100}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/resize?h=100&w=100") }
            it { expect(subject.resize("dockerapi",  {h: 100, w: 100}).request_params[:method]).to eq(:post) }
            it { expect{subject.resize("dockerapi",  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter) }
        end

        describe ".details" do
            before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :port => 2375 }, { headers: {'Content-Type': 'application/json'}, body: '{"Name":"/dockerapi"}', status: 200 }) }
            after(:all) { Excon.unstub({ :method => :get }) }
            it { expect(subject.details("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/json") }
            it { expect(subject.details("dockerapi", {size: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/json?size=true") }
            it { expect(subject.details("dockerapi").request_params[:method]).to eq(:get) }
            it { expect(subject.details("dockerapi").body).to match(/\"Name\":\"\/dockerapi\"/) }
            it { expect{subject.details("dockerapi",  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".logs" do
            it { expect(subject.logs("dockerapi",  {stdout: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/logs?stdout=true") }
            it { expect(subject.logs("dockerapi",  {stderr: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/logs?stderr=true") }
            it { expect(subject.logs("dockerapi",  {follow: false, stdout: true, stderr: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/logs?follow=false&stdout=true&stderr=true") }
            it { expect(subject.logs("dockerapi",  {stdout: true, since: 0}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/logs?stdout=true&since=0") }
            it { expect(subject.logs("dockerapi",  {stdout: true, until: 999999999}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/logs?stdout=true&until=999999999") }
            it { expect(subject.logs("dockerapi",  {stdout: true, timestamps: true}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/logs?stdout=true&timestamps=true") }
            it { expect(subject.logs("dockerapi",  {stdout: true, tail: "all"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/logs?stdout=true&tail=all") }
            it { expect{subject.logs("dockerapi",  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".changes" do
            before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :port => 2375 }, { headers: {'Content-Type': 'application/json'}, body: '[]', status: 200 }) }
            after(:all) { Excon.unstub({ :method => :get }) }
            it { expect(subject.changes("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/changes") }
            it { expect(subject.changes("dockerapi").request_params[:method]).to eq(:get) }
            it { expect(subject.changes("dockerapi").json).to be_kind_of(Array) }
        end

        describe ".stats" do
            it { expect(subject.stats("dockerapi", {stream: false}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/stats?stream=false") }
            it { expect(subject.stats("dockerapi", {stream: false}).request_params[:method]).to eq(:get) }
            it { expect{subject.stats("dockerapi",  {invalid_value: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".export" do
            before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :port => 2375 }, { headers: {'Content-Type': 'text'}, body: 'a', status: 200 }) }
            after(:all) do 
                Excon.unstub({ :method => :get })
                File.delete(File.expand_path("~/exported_container"))
            end
            it { expect{File.open(File.expand_path("~/exported_container"))}.to raise_error(Errno::ENOENT) }
            it { expect(subject.export("dockerapi", "~/exported_container").status).to eq(200) }
            it { expect{File.open(File.expand_path("~/exported_container"))}.not_to raise_error }
        end

        describe ".update" do
            it { expect(subject.update("dockerapi", {RestartPolicy: {Name: "unless-stopped"}}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/update") }
            it { expect(subject.update("dockerapi", {RestartPolicy: {Name: "unless-stopped"}}).request_params[:method]).to eq(:post) }
            it { expect(subject.update("dockerapi", {RestartPolicy: {Name: "unless-stopped"}}).request_params[:body]).to eq('{"RestartPolicy":{"Name":"unless-stopped"}}') }
            it { expect{subject.update("dockerapi", {invalid: "invalid"})}.to raise_error(Docker::API::InvalidRequestBody) }    
        end

        describe ".rename" do
            it { expect(subject.rename("dockerapi", {name: "new_name"}).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/rename?name=new_name") }
            it { expect(subject.rename("dockerapi", {name: "new_name"}).request_params[:method]).to eq(:post) }
        end

        describe ".attach" do
            it { expect(subject.attach("dockerapi").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/dockerapi/attach") }
            it { expect(subject.attach("dockerapi").request_params[:method]).to eq(:post) }
            it { expect{subject.attach("dockerapi",  {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end

        describe ".prune" do
            before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :post, :port => 2375 }, { headers: {'Content-Type': 'application/json'}, body: '{}', status: 200 }) }
            after(:all) { Excon.unstub({ :method => :post }) }

            it { expect(subject.prune.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/containers/prune") }
            it { expect(subject.prune.request_params[:method]).to eq(:post) }
            it { expect(subject.prune.json).to be_kind_of(Hash) }
            it { expect{described_class.new.prune( {invalid: "invalid"})}.to raise_error(Docker::API::InvalidParameter)  }
        end
    end
end