RSpec.describe Foobara::RubyDocumentation::LoadFoobaraProjectsFromRubyGemsDotOrg do
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

  before do
    Foobara::RubyDocumentation::FoobaraProject.all.each(&:hard_delete!)

    old_cmd = described_class.find_all_project_names_cmd
    # Adding a "e" to limit it to fewer results for a faster test
    allow(described_class).to receive(:find_all_project_names_cmd).and_return("#{old_cmd}e")
  end

  it "is successful" do
    expect {
      expect(outcome).to be_success
    }.to change(Foobara::RubyDocumentation::FoobaraProject, :count).from(0)
    expect(described_class).to have_received(:find_all_project_names_cmd)
  end
end
