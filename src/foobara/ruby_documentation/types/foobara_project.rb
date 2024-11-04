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
    end
  end
end
