RSpec.describe Docker::API do
  it "has a version number" do
    expect(Docker::API::VERSION).not_to be nil
  end
end
