module Ari
  module Generators
    class Model

      def initialize(klass_name, resource, specification)
        @klass_name = klass_name
        @resource = resource
        @specification = specification
      end

      def name
        klass_name.underscore
      end

      def klass_name
        @klass_name
      end

      def description
        @specification['description']
      end

      def properties
        @properties ||= @specification['properties'].map { |name, options| Property.new(name, options) }
      end

      def sub_types
        @specification['subTypes'] || []
      end

      def inherits_from
        inherits_from_model = @resource.models.detect { |m| m.sub_types.include?(klass_name) }
        inherits_from_model ? inherits_from_model.klass_name : 'Model'
      end

    end
  end
end