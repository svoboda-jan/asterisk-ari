module Ari
  module Generators
    class Api

      def initialize(specification)
        @specification = specification
      end

      def path
        @specification['path'].gsub(/(\{[A-z]*\})/) { "%#{$1}" }
      end

      def description
        @specification['description']
      end

      def operations
        @operations ||= @specification['operations'].map { |op| Operation.new(op) }
      end

    end
  end
end
