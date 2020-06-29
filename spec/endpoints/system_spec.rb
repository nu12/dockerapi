# source: https://zverok.github.io/blog/2017-11-01-rspec-method-call.html

RSpec.describe Docker::API::System do
    
    
    describe "::auth" do
        subject { lambda { | params | described_class.auth(params) } }
        it { expect(described_class).to respond_to(:auth) }
        it { expect{subject.call(username: "", password: "", email: "", serveraddress: "", identitytoken: "")}.not_to raise_error }
        it { expect{subject.call(invalid: true)}.to raise_error(Docker::API::InvalidRequestBody) }
    end

    describe "::ping" do
        it { expect(described_class).to respond_to(:ping) }
        it { expect(described_class.ping.status).to eq(200) }
        it { expect(described_class.ping.path).to eq("/_ping") }
    end

    describe "::info" do
        subject { described_class.info }
        it { expect(described_class).to respond_to(:info) }
        it { expect(subject.status).to eq(200) }
        it { expect(subject.success?).to eq(true) }
        it { expect(subject.json).to be_kind_of(Hash) }
        it { expect(subject.path).to eq("/info") }
    end

    describe "::version" do
        subject { described_class.version }
        it { expect(described_class).to respond_to(:version) }
        it { expect(subject.status).to eq(200) }
        it { expect(subject.success?).to eq(true) }
        it { expect(subject.json).to be_kind_of(Hash) }
        it { expect(subject.path).to eq("/version") }
    end

    describe "::events" do
        let(:now) { Time.now.to_i }
        subject { described_class.events(until: now ) }
        it { expect(described_class).to respond_to(:events) }
        it { expect(subject.status).to eq(200) }
        it { expect(subject.success?).to eq(true) }
        it { expect(subject.path).to eq("/events?until=#{now}") }
        it { expect{described_class.events(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
    end

    describe "::df" do
        subject { described_class.df }
        it { expect(described_class).to respond_to(:df) }
        it { expect(subject.status).to eq(200) }
        it { expect(subject.success?).to eq(true) }
        it { expect(subject.json).to be_kind_of(Hash) }
        it { expect(subject.path).to eq("/system/df") }
    end
end

    
  

      