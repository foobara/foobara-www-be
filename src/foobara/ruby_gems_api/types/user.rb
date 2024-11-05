module Foobara
  module RubyGemsApi
    class User < Foobara::Model
      attributes do
        id :integer, :required
        handle :string, :required
      end
    end
  end
end
