RSpec.describe Docker::API::Plugin do
    plugin = "vieux/sshfs"
    myplugin = "rspec-plugin"
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

    context "after .install" do
        before(:all) { described_class.new.install({remote: plugin}, privileges) }
        after(:all) { described_class.new.remove(plugin, force: true) }

        describe ".details" do
            it { expect(subject.details(plugin).status).to eq(200) }
            it { expect(subject.details("doesn-exist").status).to eq(404) }
        end

        describe ".configure" do
            it { expect(subject.configure(plugin, ["DEBUG=1"]).status).to eq(204) }
            it { expect(subject.configure("doesn-exist", ["DEBUG=1"]).status).to eq(404) }
        end

        describe ".enable" do
            before(:each) { subject.disable(plugin) }
            it { expect(subject.enable(plugin).status).to eq(500) }
            it { expect(subject.enable(plugin, timeout: 0).status).to eq(200) }
            it { expect(subject.enable("doesn-exist").status).to eq(500) }
            it { expect(subject.enable("doesn-exist", timeout: 10).status).to eq(404) }
            it { expect{subject.enable(plugin, invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.enable(plugin, invalid: true, skip_validation: true)}.not_to raise_error }
        end

        describe ".disable" do
            before(:each) { subject.enable(plugin, timeout: 0) }
            it { expect(subject.disable(plugin).status).to eq(200) }
            it { expect(subject.enable("doesn-exist").status).to eq(500) }
        end

        describe ".upgrade" do
            before(:all) { described_class.new.disable(plugin) }
            it { expect(subject.upgrade(plugin, {remote: plugin}).status).to eq(200) }
            it { expect(subject.upgrade(plugin, {remote: plugin}).body).to match(/incorrect/) }
            it { expect(subject.upgrade(plugin, {remote: plugin}, privileges).status).to eq(200) }
            it { expect(subject.upgrade(plugin, {remote: plugin}, privileges).body).not_to match(/incorrect/) }
            it { expect{subject.upgrade(plugin, remote: plugin, invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.upgrade(plugin, remote: plugin, invalid: true, skip_validation: true)}.not_to raise_error }
        end

        describe ".remove" do
            it { expect(subject.remove(plugin).status).to eq(200) }
            it { expect(subject.remove(plugin).status).to eq(404) }
            it { expect(subject.remove(plugin, force: true).status).to eq(404) }
            it { expect{subject.remove(plugin, invalid: true)}.to raise_error(Docker::API::InvalidParameter) }
            it { expect{subject.remove(plugin, invalid: true, skip_validation: true)}.not_to raise_error }
        end
    end

    context "create a plugin" do
        after(:all) { described_class.new.remove(myplugin) }
        describe ".create" do
            it { expect(subject.create(myplugin, "resources/plugin.tar").status).to eq(204) }
            it { expect(subject.create(myplugin, "resources/plugin.tar").status).to eq(409) }
            it { expect{subject.create(myplugin, "doesn-exist")}.to raise_error(Errno::ENOENT) }
        end

        describe ".push" do
            it { expect(subject.push(myplugin).status).to eq(200) }
            it { expect(subject.push(myplugin).json.last[:error]).not_to be(nil) }
            it { expect(subject.push("doesn-exist").status).to eq(404) }
        end
    end
end