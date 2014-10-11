module Ari
  module Generators
    class Attribute

      def initialize(specification)
        @specification = specification
      end

      def name
        @specification['name']
      end

      def description
        @specification['description']
      end

      def location
        @specification['paramType']
      end

      def required?
        @specification['required']
      end

      def multiple?
        @specification['allowMultiple']
      end

      def type
        @specification['dataType']
      end

    end
  end
end