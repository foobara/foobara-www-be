module Foobara
  module RubyDocumentation
    class FoobaraProject < Foobara::Entity
      attributes do
        gem_name :string
        homepage :string
        description :string
        versions [:string]
      end

      primary_key :gem_name

      def latest_version
        versions.first
      end

      def latest_build_versions
        @latest_build_versions ||= begin
          numeric_versions = versions.map do |version|
            version.split(".").map(&:to_i)
          end

          by_minor = {}

          numeric_versions.each do |version|
            minor = [version[0], version[1]]

            by_minor[minor] ||= []
            by_minor[minor] << version
          end

          by_minor.values.map(&:max).map do |numeric_version|
            numeric_version.join(".")
          end
        end
      end
    end
  end
end
