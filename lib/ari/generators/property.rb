module Ari
  module Generators
    class Property

      def initialize(name, specification)
        @name = name
        @specification = specification
      end

      def name
        @name
      end

      def required?
        @specification['required']
      end

      def type
        if @specification['type'].start_with?('List[')
          @specification['type'][5..-2]
        else
          @specification['type'] == 'void' ? nil : @specification['type']
        end
      end

      def description
        @specification['description']
      end

    end
  end
end