RSpec.describe "Support multiple Docker API versions" do

    context "with stubs" do
        before(:all) { Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :method => :get, :port => 2375 }, {headers: {'Content-Type': 'application/json'}, body: '[]', status: 200 })  }
        after(:all) { Excon.unstub({ :method => :get }) }
        
        describe "default version" do
            subject { Docker::API::Container.new(stub_connection) }    
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API.default_api_version}/containers/json") }
        end

        describe "overwriting the default version" do
            subject = Docker::API::Container.new(stub_connection)
            
            it { expect{subject.api_version="1.45"}.not_to raise_error }
            it { expect(subject.api_version).to eq("1.45") }
            it { expect(subject.list.request_params[:path]).to eq("/v1.45/containers/json") }
        end

        describe "using a different default version" do
            Docker::API.default_api_version = "1.47"
            subject = Docker::API::Container.new(stub_connection)
            Docker::API.default_api_version = "1.43"

            it { expect(subject.api_version).to eq("1.47") }
            it { expect(subject.list.request_params[:path]).to eq("/v1.47/containers/json") }
        end
    end
end