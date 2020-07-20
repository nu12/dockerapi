RSpec.describe Docker::API::Plugin do
    plugin = "vieux/sshfs"
    privileges = Docker::API::Plugin.new.privileges(remote: plugin).json
    subject { described_class.new }
    it { is_expected.to respond_to(:list) }
    it { is_expected.to respond_to(:privileges) }
    it { is_expected.to respond_to(:install) }
    it { is_expected.to respond_to(:details) }
    it { is_expected.to respond_to(:remove) }
    it { is_expected.to respond_to(:enable) }
    it { is_expected.to respond_to(:disable) }
    it { is_expected.to respond_to(:upgrade) }
    it { is_expected.to respond_to(:create) }
    it { is_expected.to respond_to(:push) }
    it { is_expected.to respond_to(:configure) }

    describe ".list" do
        it { expect(subject.list.status).to eq(200) }
        it { expect(subject.list(filters: {capability: { "name": true }}).status).to eq(200) }
        it { expect(subject.list(filters: {enable: { "true": true }}).status).to eq(400) }
        it { expect{subject.list(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        it { expect{subject.list(invalid: true, skip_validation: true)}.not_to raise_error }
    end

    describe ".privileges" do
        it { expect(subject.privileges.status).to eq(500) }
        it { expect(subject.privileges(remote: plugin).status).to eq(200) }
        it { expect{subject.privileges(invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        it { expect{subject.privileges(invalid: true, skip_validation: true)}.not_to raise_error }
    end

    describe ".install" do
        after(:each) { subject.remove(plugin) }
        it { expect(subject.install.status).to eq(500) }
        it { expect(subject.install(remote: plugin).status).to eq(200) }
        it { expect(subject.install(remote: plugin).body).to match(/incorrect/) }
        it { expect(subject.install(remote: plugin, name: "local-name").status).to eq(200) }
        it { expect(subject.install(remote: plugin, name: "local-name").body).to match(/incorrect/) }
        it { expect(subject.install({remote: plugin}, privileges).status).to eq(200) }
        it { expect(subject.install({remote: plugin}, privileges).body).not_to match(/incorrect/) }
        it { expect{subject.install(remote: plugin, invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
        it { expect{subject.install(remote: plugin, invalid: true, skip_validation: true)}.not_to raise_error }
    end
end