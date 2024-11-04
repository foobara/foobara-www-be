module Foobara
  module RubyDocumentation
    class GenerateLatestForEachGem < Foobara::Command
      result :string

      depends_on_entity Foobara::RubyDocumentation::FoobaraProject

      def execute
        load_projects

        each_project do
          generate_yard_documentation
        end

        stitch_into_one_page

        "todo: figure out what to return"
      end

      attr_accessor :projects, :project

      def load_projects
        self.projects = Foobara::RubyDocumentation::FoobaraProject.all
      end

      def each_project
        projects.each do |project|
          self.project = project
          yield
        end
      end

      def generate_documentation
      end

      def stitch_into_one_page
      end
    end
  end
end
