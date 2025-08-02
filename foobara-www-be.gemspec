require_relative "src/version"

Gem::Specification.new do |spec|
  spec.name = "foobara-foobara-www-be"
  spec.version = Foobara::FoobaraWwwBe::VERSION
  spec.authors = ["Miles Georgi"]
  spec.email = ["azimux@gmail.com"]

  spec.summary = "No description. Add one."
  spec.homepage = "https://github.com/foobara/foobara-www-be"
  spec.license = "None specified yet"
  spec.required_ruby_version = Foobara::FoobaraWwwBe::MINIMUM_RUBY_VERSION

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.executables += ["generate-latest-foob-docs-for-each-gem"]

  spec.files = Dir[
    "lib/**/*",
    "src/**/*",
    "LICENSE*.txt",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.add_dependency "foobara", "< 2.0.0"
  spec.add_dependency "foobara-ruby-gems-api", "< 2.0.0"

  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
