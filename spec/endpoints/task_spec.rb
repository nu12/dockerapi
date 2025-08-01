RSpec.describe Docker::API::Task do
    subject { described_class.new(stub_connection) }

    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:logs) }
    
    context "with stubs" do 
        before(:all) {Excon.stub({ :scheme => 'http', :host => '127.0.0.1', :port => 2375 }, {  }) }
        after(:all) { Excon.stubs.clear }

        describe ".list" do
            it { expect(subject.list.request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks") }
            it { expect(subject.list.request_params[:method]).to eq(:get) }
            it { expect(subject.list(filters: { "desired-state": {"running": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks?filters={\"desired-state\":{\"running\":true}}") }
            it { expect(subject.list(filters: { "desired-state": {"shutdown": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks?filters={\"desired-state\":{\"shutdown\":true}}") }
            it { expect(subject.list(filters: { "desired-state": {"accepted": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks?filters={\"desired-state\":{\"accepted\":true}}") }
            it { expect(subject.list(filters: { "id": {"id-here": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks?filters={\"id\":{\"id-here\":true}}") }
            it { expect(subject.list(filters: { "name": {"task-name": true} }).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks?filters={\"name\":{\"task-name\":true}}") }
            it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.list(invalid: true, skip_validation: true)}.not_to raise_error }
        end

        describe ".details" do
            it { expect(subject.details("id").request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks/id") }
            it { expect(subject.details("id").request_params[:method]).to eq(:get) }
        end

        describe ".logs" do
            it { expect(subject.logs( "id", details: true, stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks/id/logs?details=true&stdout=true") }
            it { expect(subject.logs( "id", details: true, stderr: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks/id/logs?details=true&stderr=true") }
            it { expect(subject.logs( "id", since: 0, stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks/id/logs?since=0&stdout=true") }
            it { expect(subject.logs( "id", timestamps: 0, stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks/id/logs?timestamps=0&stdout=true") }
            it { expect(subject.logs( "id", tail: 10, stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks/id/logs?tail=10&stdout=true") }
            it { expect(subject.logs( "id", tail: "all", stdout: true ).request_params[:path]).to eq("/v#{Docker::API::API_VERSION}/tasks/id/logs?tail=all&stdout=true") }
            it { expect{subject.logs( "id", invalid: true )}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.logs( "id", invalid: true, skip_validation: true )}.not_to raise_error }
        end
    end
end