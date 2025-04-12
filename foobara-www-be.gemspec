require_relative "src/version"

local_ruby_version = File.read("#{__dir__}/.ruby-version").chomp
local_ruby_version_minor = local_ruby_version[/\A(\d+\.\d+)\.\d+\z/, 1]
minimum_ruby_version = "#{local_ruby_version_minor}.0"

Gem::Specification.new do |spec|
  spec.name = "foobara-foobara-www-be"
  spec.version = Foobara::FoobaraWwwBe::VERSION
  spec.authors = ["Miles Georgi"]
  spec.email = ["azimux@gmail.com"]

  spec.summary = "No description. Add one."
  spec.homepage = "https://github.com/foobara/foobara-www-be"
  spec.license = "None specified yet"
  spec.required_ruby_version = ">= #{minimum_ruby_version}"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.executables += ["foob-docs"]

  spec.files = Dir[
    "lib/**/*",
    "src/**/*",
    "LICENSE*.txt",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.add_dependency "foobara", "~> 0.0.96"
  spec.add_dependency "foobara-ruby-gems-api", "~> 0.0.1"

  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
