RSpec.describe Foobara::RubyDocumentation::QueryFoobaraProjects do
  let(:command) { described_class.new }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:errors_hash) { outcome.errors_hash }

  around do |example|
    Foobara::RubyDocumentation::FoobaraProject.transaction do
      example.run
    end
  end

  context "when there are projects" do
    let!(:project1) do
      Foobara::RubyDocumentation::FoobaraProject.create(
        gem_name: "gem1",
        homepage: "Homepage One",
        description: "some gem",
        versions: ["1.0.0", "2.0.0"]
      )
    end

    let!(:project2) do
      Foobara::RubyDocumentation::FoobaraProject.create(
        gem_name: "gem2",
        homepage: "Homepage Two",
        description: "some gem",
        versions: ["1.0.0", "2.0.0"]
      )
    end

    it "is returns projects" do
      expect(outcome).to be_success
      expect(result).to eq([project1, project2])
    end
  end
end
