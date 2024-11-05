RSpec.describe Foobara::RubyGemsApi::Search do
  let(:command) { described_class.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:errors_hash) { outcome.errors_hash }

  let(:inputs) do
    { query: "foobara" }
  end

  it "is successful", :focus, vcr: { record: :once } do
    expect(outcome).to be_success
    expect(result).to be_an(Array)
  end
end
