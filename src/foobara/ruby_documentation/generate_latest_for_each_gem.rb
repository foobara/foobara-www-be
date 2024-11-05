require "fileutils"
require "open3"

module Foobara
  module RubyDocumentation
    class GenerateLatestForEachGem < Foobara::Command
      inputs do
        output_dir :string, default: "~/tmp/foobara_docs"
      end

      result :string

      depends_on LoadFoobaraProjectsFromRubyGemsDotOrg
      depends_on_entity Foobara::RubyDocumentation::FoobaraProject

      def execute
        load_projects

        each_project do
          install_gem
          generate_yard_documentation
        end

        stitch_into_one_page

        "todo: figure out what to return"
      end

      attr_accessor :projects, :project

      def load_projects
        puts "loading projects..."
        self.projects = run_subcommand!(LoadFoobaraProjectsFromRubyGemsDotOrg)
      end

      def each_project
        projects.each do |project|
          self.project = project
          yield
        end
      end

      def install_gem
        gem_version = project.versions.first

        Bundler.with_unbundled_env do
          Open3.popen3("gem install #{project.gem_name} -v #{gem_version}") do |_stdin, _stdout, stderr, wait_thr|
            exit_status = wait_thr.value
            unless exit_status.success?
              # :nocov:
              warn "WARNING: could not rubocop -A. #{stderr.read}"
              # :nocov:
            end
          end
        end
      end

      def installed_path
        @installed_path ||= Bundler.with_unbundled_env do
          gem_name = project.gem_name
          gem_version = project.versions.first

          Open3.popen3("gem info #{gem_name}") do |_stdin, stdout, stderr, wait_thr|
            exit_status = wait_thr.value
            unless exit_status.success?
              # :nocov:
              warn "WARNING: could not rubocop -A. #{stderr.read}"
              # :nocov:
            end

            info_text = stdout.read

            if info_text =~ /\n\s+Installed at (\(.*)\n\n/m
              installed_at_locations = ::Regexp.last_match(1)

              if installed_at_locations =~ /^\s*\(#{project.versions.first}\): (.*)$/
                File.join(::Regexp.last_match(1), "gems", "#{gem_name}-#{gem_version}")
              else
                # :nocov:
                raise "could not find installed path for #{project.gem_name}"
                # :nocov:
              end
            else
              # :nocov:
              raise "could not find installed path for #{project.gem_name}"
              # :nocov:
            end
          end
        end
      end

      def generate_yard_documentation
        Dir.chdir installed_path do
          Bundler.with_unbundled_env do
            Open3.popen3("gem install yard") do |_stdin, _stdout, stderr, wait_thr|
              exit_status = wait_thr.value
              unless exit_status.success?
                # :nocov:
                warn "WARNING: could not rubocop -A. #{stderr.read}"
                # :nocov:
              end
            end

            projects.each do |project|
              gem_name = project.gem_name
              gem_version = project.versions.first
              gem_output_dir = File.join(output_dir, gem_name, gem_version)

              next if Dir.exist?(gem_output_dir)

              FileUtils.mkdir_p gem_output_dir

              puts "generating docs for #{gem_name} #{gem_version}"

              Open3.popen3(
                "yard doc 'projects/**/*.rb' 'src/**/*.rb' 'lib/**/*.rb' -o #{gem_output_dir}"
              ) do |_stdin, _stdout, stderr, wait_thr|
                exit_status = wait_thr.value
                unless exit_status.success?
                  # :nocov:
                  warn "WARNING: could not rubocop -A. #{stderr.read}"
                  # :nocov:
                end
              end
            end
          end
        end
      end

      def stitch_into_one_page
      end
    end
  end
end
