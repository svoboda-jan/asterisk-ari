module Ari
  module Generators
    class Operation

      def initialize(specification)
        @specification = specification
      end

      def http_method
        @specification['httpMethod']
      end

      def description
        @specification['summary']
      end

      def method_name
        @specification['nickname'].underscore
      end

      def original_method_name
        @specification['nickname']
      end

      def return_klass
        if @specification['responseClass'].start_with?('List[')
          @specification['responseClass'][5..-2]
        else
          @specification['responseClass'] == 'void' ? nil : @specification['responseClass']
        end
      end

      def returns_array?
        @specification['responseClass'].start_with?('List[')
      end

      def parameters
        @parameters ||= @specification['parameters'].map { |p| Parameter.new(p) } rescue []
      end

    end
  end
end
