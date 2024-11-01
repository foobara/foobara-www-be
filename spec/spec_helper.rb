ENV["FOOBARA_ENV"] = "test"

require "bundler/setup"

require "pry"
require "pry-byebug"
require "rspec/its"

require_relative "support/simplecov"
require_relative "../boot/start"

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.order = :defined
  config.expect_with(:rspec) do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.raise_errors_for_deprecations!
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

require "foobara/spec_helpers/all"
require_relative "../boot/finish"
