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
    FileUtils.rm_rf(output_dir)

    old_docs_dir = File.join(output_dir, "gems", "foobara-util", "0.0.5")
    FileUtils.mkdir_p(old_docs_dir)
    File.write(File.join(old_docs_dir, "junk.txt"), "hi!")

    allow(command).to receive(:run_subcommand!).with(
      Foobara::RubyDocumentation::LoadFoobaraProjectsFromRubyGemsDotOrg
    ).and_return([
                   Foobara::RubyDocumentation::FoobaraProject.build(
                     gem_name: "foobara-util",
                     homepage: "Homepage One",
                     description: "some gem",
                     versions: ["0.0.6", "0.0.5"]
                   ),
                   Foobara::RubyDocumentation::FoobaraProject.build(
                     gem_name: "foob",
                     homepage: "Homepage One",
                     description: "some gem",
                     versions: ["0.0.7"]
                   )
                 ])
  end

  it "is successful", vcr: { record: :none } do
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

  describe "#installed_path" do
    before do
      command.cast_and_validate_inputs
      command.project = Foobara::RubyDocumentation::FoobaraProject.build(
        gem_name: "foob",
        homepage: "Homepage One",
        description: "some gem",
        versions: ["0.0.7"]
      )
      command.version = "0.0.7"

      allow(command).to receive(:read_gem_info).and_return(gem_info_text)
    end

    context "when two versions of a gem are installed" do
      let(:gem_info_text) do
        <<~HERE
          foob (0.0.7, 0.0.6)
          Author: Miles Georgi
          Homepage: https://github.com/foobara/foob
          Licenses: Apache-2.0, MIT
          Installed at (0.0.7): /home/miles/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0
          (0.0.6): /home/miles/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0

          foob: cli interface for code generators and whatnot for Foobara
          projects
        HERE
      end

      it "gives the expected installed path" do
        expect(command.installed_path).to eq("/home/miles/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/foob-0.0.7")
      end
    end

    context "when only one version of a gem is installed" do
      let(:gem_info_text) do
        <<~HERE
          foob (0.0.6)
          Author: Miles Georgi
          Homepage: https://github.com/foobara/foob
          Licenses: Apache-2.0, MIT
          Installed at: /home/miles/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0

          foob: cli interface for code generators and whatnot for Foobara
          projects
        HERE
      end

      it "gives the expected installed path" do
        expect(command.installed_path).to eq("/home/miles/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/foob-0.0.7")
      end
    end
  end
end
