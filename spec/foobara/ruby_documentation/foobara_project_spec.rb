RSpec.describe Foobara::RubyDocumentation::FoobaraProject do
  describe "#latest_version" do
    let(:project) do
      described_class.build(
        gem_name: "foobara-util",
        homepage: "example.com",
        description: "some gem",
        versions: ["0.0.6", "0.0.5"]
      )
    end

    it "returns the latest version" do
      expect(project.latest_version).to eq("0.0.6")
    end
  end
end
