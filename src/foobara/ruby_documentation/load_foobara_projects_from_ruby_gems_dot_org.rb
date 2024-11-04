module Foobara
  module RubyDocumentation
    class LoadFoobaraProjectsFromRubyGemsDotOrg < Foobara::Command
      result [FoobaraProject]

      def execute
        delete_all_projects

        find_all_project_names
        filter_by_owner
        create_foobara_projects

        projects
      end

      class << self
        def find_all_project_names_cmd
          "gem list --remote '^foobara(\b|-)'"
        end
      end

      attr_accessor :projects, :project

      def delete_all_projects
        # TODO: why isn't there a delete_all method?
        Foobara::RubyDocumentation::FoobaraProject.all.each(&:hard_delete!)
      end

      def project_names
        @project_names ||= []
      end

      def find_all_project_names_cmd
        self.class.find_all_project_names_cmd
      end

      def find_all_project_names
        Open3.popen3(find_all_project_names_cmd) do |_stdin, stdout, stderr, wait_thr|
          stdout.each_line do |line|
            if line =~ /^(foobara(?:-[\w-]+)?) \(/
              project_names << ::Regexp.last_match(1)
            end
          end

          exit_status = wait_thr.value
          unless exit_status.success?
            # :nocov:
            raise "ERROR: could not #{cmd} #{stderr.read}"
            # :nocov:
          end
        end
      end

      def filter_by_owner
        project_names.select! do |project_name|
          cmd = "gem owner #{project_name}"
          Open3.popen3(cmd) do |_stdin, stdout, stderr, wait_thr|
            exit_status = wait_thr.value
            unless exit_status.success?
              # :nocov:
              raise "ERROR: could not #{cmd} #{stderr.read}"
              # :nocov:
            end

            stdout.read =~ /^- azimux$/
          end
        end
      end

      def create_foobara_projects
        project_names.each do |project_name|
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
