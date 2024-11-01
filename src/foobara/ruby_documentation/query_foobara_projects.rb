module Foobara
  module RubyDocumentation
    class QueryFoobaraProjects < Foobara::Command
      result [FoobaraProject]

      def execute
        load_all_foobara_projects
      end

      attr_accessor :foobara_projects

      def load_all_foobara_projects
        self.foobara_projects = FoobaraProject.all
      end
    end
  end
end
