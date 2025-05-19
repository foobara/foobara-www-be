require "bundler/gem_tasks"

task :environment do
  require_relative "boot"
end

require_relative "config/application"

Rails.application.load_tasks
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: [:spec, :rubocop]
