require_relative "../ruby_gems_api/search"
require_relative "../ruby_gems_api/get_owners"

module Foobara
  module RubyDocumentation
    class LoadFoobaraProjectsFromRubyGemsDotOrg < Foobara::Command
      result [FoobaraProject]

      depends_on Foobara::RubyGemsApi::Search,
                 Foobara::RubyGemsApi::GetOwners

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

          puts "processing #{project_name}"
          cmd = "gem info --remote --all -e #{project_name}"
          Open3.popen3(cmd) do |_stdin, stdout, stderr, wait_thr|
            exit_status = wait_thr.value
            unless exit_status.success?
              # :nocov:
              raise "ERROR: could not #{cmd} #{stderr.read}"
              # :nocov:
            end

            gem_info = stdout.read
            regex = /^#{project_name} \(([\d\., ]+)\)\n.*\n    Homepage:\s+([.\w:\/-]+)\n.*\n\n(.*)\z/m

            if gem_info =~ regex
              version_string = ::Regexp.last_match(1)
              homepage = ::Regexp.last_match(2)
              description_string = ::Regexp.last_match(3)

              versions = version_string.split(",").map(&:strip)
              description = description_string.split("\n").map(&:strip).join("\n")

              FoobaraProject.create(
                gem_name: project_name,
                description:,
                versions:,
                homepage:
              )
            else
              # :nocov:
              raise "ERROR: could not parse #{gem_info}"
              # :nocov:
            end
          end
        end
      end
    end
  end
end
