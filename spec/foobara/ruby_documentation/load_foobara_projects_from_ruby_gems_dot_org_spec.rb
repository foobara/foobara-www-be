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
  end

  it "is successful", vcr: { record: :none } do
    expect {
      expect(outcome).to be_success
    }.to change(Foobara::RubyDocumentation::FoobaraProject, :count).from(0)
  end
end
