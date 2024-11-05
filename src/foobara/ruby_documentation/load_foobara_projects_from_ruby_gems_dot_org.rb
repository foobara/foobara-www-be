require_relative "../ruby_gems_api/search"
require_relative "../ruby_gems_api/get_owners"
require_relative "../ruby_gems_api/get_versions"

module Foobara
  module RubyDocumentation
    class LoadFoobaraProjectsFromRubyGemsDotOrg < Foobara::Command
      result [FoobaraProject]

      depends_on Foobara::RubyGemsApi::Search,
                 Foobara::RubyGemsApi::GetOwners,
                 Foobara::RubyGemsApi::GetVersions

      def execute
        delete_all_projects

        find_all_project_gems
        filter_by_owner
        create_foobara_projects

        projects
      end

      attr_accessor :projects, :project, :project_gems

      def delete_all_projects
        # TODO: why isn't there a delete_all method?
        Foobara::RubyDocumentation::FoobaraProject.all.each(&:hard_delete!)
      end

      def find_all_project_gems
        self.project_gems = run_subcommand!(Foobara::RubyGemsApi::Search, query: "foobara")
      end

      def filter_by_owner
        project_gems.select! do |project_gem|
          project_name = project_gem.name

          owners = run_subcommand!(Foobara::RubyGemsApi::GetOwners, gem_name: project_name)

          owners.any? { |owner| owner.handle == "azimux" }
        end
      end

      def create_foobara_projects
        project_gems.each do |project_gem|
          project_name = project_gem.name
          description = project_gem.info
          homepage = project_gem.homepage_uri
          versions = run_subcommand!(RubyGemsApi::GetVersions, gem_name: project_name)

          FoobaraProject.create(
            gem_name: project_name,
            description:,
            versions: versions.map(&:number),
            homepage:
          )
        end
      end
    end
  end
end
