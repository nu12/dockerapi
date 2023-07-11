RSpec.describe Docker::API::System do
    subject { described_class.new } 
    describe ".auth" do
        it { expect(subject).to respond_to(:auth) }
        it { expect{subject.auth(username: "", password: "", email: "", serveraddress: "", identitytoken: "")}.not_to raise_error }
        it { expect{subject.auth(invalid: true)}.to raise_error(Docker::API::InvalidRequestBody) }
        it { expect{subject.auth(invalid: true, skip_validation: true)}.not_to raise_error }
    end

    describe ".ping" do
        it { expect(subject).to respond_to(:ping) }
        it { expect(subject.ping.status).to eq(200) }
        it { expect(subject.ping.path).to eq("/_ping") }
    end

    describe ".info" do
        it { expect(subject).to respond_to(:info) }
        it { expect(subject.info.status).to eq(200) }
        it { expect(subject.info.success?).to eq(true) }
        it { expect(subject.info.json).to be_kind_of(Hash) }
        it { expect(subject.info.path).to eq("/info") }
    end

    describe ".version" do
        it { expect(subject).to respond_to(:version) }
        it { expect(subject.version.status).to eq(200) }
        it { expect(subject.version.success?).to eq(true) }
        it { expect(subject.version.json).to be_kind_of(Hash) }
        it { expect(subject.version.path).to eq("/version") }
    end

    describe ".events" do
        let(:now) { Time.now.to_i }
        subject { described_class.new.events(until: now ) }
        it { expect(described_class.new).to respond_to(:events) }
        it { expect(subject.status).to eq(200) }
        it { expect(subject.success?).to eq(true) }
        it { expect(subject.path).to eq("/events?until=#{now}") }
        it { expect{described_class.new.events(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        it { expect{described_class.new.events(invalid: true, skip_validation: false)}.to raise_error(Docker::API::InvalidParameter) }
    end

    describe ".df" do
        it { expect(subject).to respond_to(:df) }
        it { expect(subject.df.status).to eq(200) }
        it { expect(subject.df.success?).to eq(true) }
        it { expect(subject.df.json).to be_kind_of(Hash) }
        it { expect(subject.df.path).to eq("/system/df") }
        it { expect{subject.df(invalid: "true")}.to raise_error(Docker::API::InvalidParameter) }
        it { expect{subject.df(type: "container")}.not_to raise_error }
        it { expect(subject.df(type: "container").path).to eq("/system/df?type=container" )}
    end
end