require 'erb'
require 'active_support'
require 'active_support/core_ext'
require 'ari/generators/api'
require 'ari/generators/attribute'
require 'ari/generators/model'
require 'ari/generators/operation'
require 'ari/generators/parameter'
require 'ari/generators/property'

module Ari
  module Generators
    class ResourceGenerator

      def initialize(resource_name, specification, options = {})
        @resource_name = resource_name.underscore
        @klass_name = @resource_name.classify
        @specification = specification
        @options = options
      end

      def template_path(klass)
        File.join(__dir__, 'templates', "#{klass}.rb.erb")
      end

      def destination_path(klass)
        File.join(__dir__, '..', klass)
      end

      def generate_only_models?
        @options.fetch(:only_models, false)
      end

      def generate
        generate_resource
        generate_models
      end

      def generate_resource
        erb = ERB.new(IO.read(template_path('resource')), nil, '-')
        File.open(File.join(destination_path('resources'), "#{resource_name}.rb"), 'w') do |f|
          f.write erb.result(binding)
        end
      end

      def generate_models
        erb = ERB.new(IO.read(template_path('model')), nil, '-')
        models.each do |model|
          next if model.name == resource_name
          File.open(File.join(destination_path('models'), "#{model.name}.rb"), 'w') do |f|
            f.write erb.result(model.instance_eval { binding })
          end
        end
      end

      def klass_name
        @klass_name
      end

      def resource_klass_name
        options.fetch(:resource_klass_name, klass_name)
      end

      def resource_attributes
        models.detect { |m| m.klass_name == klass_name }.properties rescue []
      end

      def resource_name
        @resource_name.singularize
      end

      def resource_plural_name
        @resource_name
      end

      def id_attribute_name
        @options.fetch(:id_attribute_name, "#{klass_name.camelcase(:lower)}Id")
      end

      def apis
        @apis ||= @specification['apis'].map { |api| Api.new(api) }
      end

      def models
        @models ||= @specification['models'].map { |klass_name, options| Model.new(klass_name, self, options) }
      end

      def inherits_from
        generate_only_models? ? 'Model' : 'Resource'
      end

    end
  end
end
