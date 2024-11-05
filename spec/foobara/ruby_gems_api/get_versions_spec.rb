RSpec.describe Foobara::RubyGemsApi::GetVersions do
  let(:command) { described_class.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:errors_hash) { outcome.errors_hash }

  let(:inputs) do
    { gem_name: "foobara" }
  end

  it "is successful", vcr: { record: :none } do
    expect(outcome).to be_success
    expect(result).to be_an(Array)
  end
end
