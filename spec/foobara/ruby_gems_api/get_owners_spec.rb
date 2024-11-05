RSpec.describe Foobara::RubyGemsApi::GetOwners do
  let(:command) { described_class.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:errors_hash) { outcome.errors_hash }

  let(:inputs) do
    { gem_name: "foobara" }
  end

  it "is successful",  vcr: { record: :once } do
    expect(outcome).to be_success
    expect(result).to be_an(Array)
    expect(result.map(&:handle)).to include("azimux")
  end
end
