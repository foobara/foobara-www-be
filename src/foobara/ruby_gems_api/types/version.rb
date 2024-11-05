module Foobara
  module RubyGemsApi
    class Version < Foobara::Model
      attributes do
        authors :string
        built_at :datetime, :required
        created_at :datetime, :required
        description :string, :allow_nil
        downloads_count :integer, :required
        metadata do
          homepage_uri :string, :allow_nil
          changelog_uri :string, :allow_nil
          source_code_uri :string, :allow_nil
          rubygems_mfa_required :boolean
        end
        number :string, :required
        summary :string
        platform :string
        rubygems_version :string
        ruby_version :string
        prerelease :boolean
        licenses [:string]
        requirements [:string]
        sha :string, :required
        spec_sha :string, :required
      end
    end
  end
end
