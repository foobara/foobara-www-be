RSpec.describe Foobara::RubyDocumentation::GenerateLatestForEachGem do
  let(:command) { described_class.new(inputs) }
  let(:inputs) { { output_dir: } }
  let(:output_dir) { "#{__dir__}/../../../tmp/docs" }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:errors_hash) { outcome.errors_hash }

  around do |example|
    Foobara::RubyDocumentation::FoobaraProject.transaction do
      example.run
    end
  end

  before do
    Bundler.with_unbundled_env do
      # NOTE: trying to create a situation where there's multiple installed versions of a gem to test certain code paths
      system("gem install foobara-util -v 0.0.5")
    end

    FileUtils.rm_rf(output_dir)

    allow(command).to receive(:run_subcommand!).with(
      Foobara::RubyDocumentation::LoadFoobaraProjectsFromRubyGemsDotOrg
    ).and_return([
                   Foobara::RubyDocumentation::FoobaraProject.build(
                     gem_name: "foobara-util",
                     homepage: "Homepage One",
                     description: "some gem",
                     versions: ["0.0.6"]
                   ),
                   Foobara::RubyDocumentation::FoobaraProject.build(
                     gem_name: "foob",
                     homepage: "Homepage One",
                     description: "some gem",
                     versions: ["0.0.6"]
                   )
                 ])
  end

  it "is successful",  vcr: { record: :none } do
    expect(outcome).to be_success
    expect(command).to have_received(:run_subcommand!).with(
      Foobara::RubyDocumentation::LoadFoobaraProjectsFromRubyGemsDotOrg
    )
    expect(result).to be_a(Hash)

    command2 = described_class.new(inputs)

    allow(command2).to receive(:run_subcommand!).with(
      Foobara::RubyDocumentation::LoadFoobaraProjectsFromRubyGemsDotOrg
    ).and_return([
                   Foobara::RubyDocumentation::FoobaraProject.build(
                     gem_name: "foobara-util",
                     homepage: "Homepage One",
                     description: "some gem",
                     versions: ["0.0.6"]
                   )
                 ])
    outcome2 = command2.run
    expect(outcome2).to be_success
    expect(outcome2.result).to be_a(Hash)
  end
end
