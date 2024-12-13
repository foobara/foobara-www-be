require "fileutils"
require "open3"

module Foobara
  module RubyDocumentation
    class GenerateLatestForEachGem < Foobara::Command
      inputs do
        output_dir :string, default: "#{Dir.home}/tmp/foobara_docs"
      end

      result ::Hash

      depends_on LoadFoobaraProjectsFromRubyGemsDotOrg
      depends_on_entity Foobara::RubyDocumentation::FoobaraProject

      def execute
        load_projects

        each_project do
          each_version do
            if latest_version?
              install_gem
              generate_yard_documentation
            else
              delete_yard_documentation
            end
          end
        end

        stitch_into_one_page
        write_documentation_json

        stats
      end

      attr_accessor :projects, :project, :version

      def load_projects
        puts "loading projects..."
        self.projects = run_subcommand!(LoadFoobaraProjectsFromRubyGemsDotOrg)
      end

      def gem_installed_paths
        @gem_installed_paths ||= []
      end

      def gem_latest_installed_paths
        @gem_latest_installed_paths ||= []
      end

      def each_project
        projects.each do |project|
          self.project = project
          yield
        end
      end

      def latest_version?
        version == project.latest_version
      end

      def each_version
        project.versions.each do |version|
          self.version = version
          yield
        end
      end

      def stats
        @stats ||= {}
      end

      def install_gem
        Bundler.with_unbundled_env do
          Open3.popen3("gem install #{project.gem_name} -v #{version}") do |_stdin, _stdout, stderr, wait_thr|
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
        gem_name = project.gem_name

        info_text = read_gem_info

        if info_text =~ /\A#{gem_name} \(([^)]+\))$/
          installed_versions = ::Regexp.last_match(1)

          has_multiple_versions = installed_versions.include?(",")

          regex = if has_multiple_versions
                    /\n\s*Installed at:? (\(.*)\n\n/m
                  else
                    /^\s*Installed at: ([^\n]+)$/
                  end

          if info_text =~ regex
            installed_at_location = if has_multiple_versions
                                      installed_at_locations = ::Regexp.last_match(1)

                                      if installed_at_locations =~ /^\s*\(#{version}\): (.*)$/
                                        ::Regexp.last_match(1)
                                      else
                                        # :nocov:
                                        raise "could not find installed path for #{project.gem_name}"
                                        # :nocov:
                                      end
                                    else
                                      ::Regexp.last_match(1)
                                    end

            File.join(installed_at_location, "gems", "#{gem_name}-#{version}")
          else
            # :nocov:
            raise "could not find installed path for #{project.gem_name}"
            # :nocov:
          end
        else
          # :nocov:
          raise "Could not find installed version for #{project.gem_name}"
          # :nocov:
        end
      end

      def read_gem_info
        Bundler.with_unbundled_env do
          gem_name = project.gem_name
          cmd = "gem info --quiet #{gem_name}"

          Open3.popen3(cmd) do |_stdin, stdout, stderr, wait_thr|
            exit_status = wait_thr.value
            unless exit_status.success?
              # :nocov:
              warn "WARNING: could not #{cmd}. #{stderr.read}"
              # :nocov:
            end

            stdout.read
          end
        end
      end

      def delete_yard_documentation
        if Dir.exist?(docs_output_dir)
          puts "deleting old docs for #{project.gem_name} #{version}"
          FileUtils.rm_rf docs_output_dir
        end
      end

      def generate_yard_documentation
        path = installed_path
        gem_installed_paths << path

        if version == project.versions.first
          gem_latest_installed_paths << path
        end

        Dir.chdir path do
          Bundler.with_unbundled_env do
            Open3.popen3("gem install yard") do |_stdin, _stdout, stderr, wait_thr|
              exit_status = wait_thr.value
              unless exit_status.success?
                # :nocov:
                warn "WARNING: could not rubocop -A. #{stderr.read}"
                # :nocov:
              end
            end

            gem_name = project.gem_name

            stats[gem_name] ||= {}
            stat = stats[gem_name][version] ||= {}

            if Dir.exist?(docs_output_dir)
              stat["status"] = "documentation already existed"
              next
            end

            FileUtils.mkdir_p docs_output_dir

            puts "generating docs for #{gem_name} #{version}"

            Open3.popen3(
              "yard doc 'projects/**/*.rb' 'src/**/*.rb' 'lib/**/*.rb' -o #{docs_output_dir}"
            ) do |_stdin, _stdout, stderr, wait_thr|
              exit_status = wait_thr.value
              unless exit_status.success?
                # :nocov:
                warn "WARNING: could not rubocop -A. #{stderr.read}"
                # :nocov:
              end
            end

            stat["status"] = "generated docs"
          end
        end
      end

      def docs_output_dir
        gem_name = project.gem_name
        File.join(output_dir, "gems", gem_name, version)
      end

      def stitch_into_one_page
        top_level_dir = File.join(output_dir, "root")
        FileUtils.rm_r top_level_dir if File.exist?(top_level_dir)
        FileUtils.mkdir_p top_level_dir
        FileUtils.rm_r File.join(output_dir, "all") if File.exist?(File.join(output_dir, "all"))

        Dir.chdir top_level_dir do
          gem_latest_installed_paths.each do |gem_installed_path|
            unless File.exist?(File.basename(gem_installed_path))
              FileUtils.ln_s(gem_installed_path, ".")
            end
          end

          Bundler.with_unbundled_env do
            Open3.popen3(
              "yard doc '*/projects/**/*.rb' '*/src/**/*.rb' '*/lib/**/*.rb' -o '../all'"
            ) do |_stdin, _stdout, stderr, wait_thr|
              exit_status = wait_thr.value
              unless exit_status.success?
                # :nocov:
                warn "WARNING: could not run yard doc. #{stderr.read}"
                # :nocov:
              end
            end
          end
        end
      end

      def write_documentation_json
        data = projects.to_h do |project|
          # For now, we just take the latest version to save space and because there's no reason to be interested
          # in docs for old versions yet
          [project.gem_name, [project.latest_version]]
        end

        json = JSON.pretty_generate(data)

        File.write(File.join(output_dir, "data.json"), json)
      end
    end
  end
end
