module Foobara
  module RubyDocumentation
    class FoobaraProject < Foobara::Entity
      attributes do
        id :integer
        gem_name :string
        english_name :string
        description :string
        versions [:string]
      end

      primary_key :id
    end
  end
end
