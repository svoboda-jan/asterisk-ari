require 'time'

module Ari
  class Model

    def initialize(attributes)
      if attributes
        @client = attributes.delete(:client)
        self.attributes = attributes
      end
    end

    def attributes=(attributes)
      attributes.each do |name, value|
        setter = "#{name}="
        if respond_to? setter
          value.merge!(client: @client) if @client && value.is_a?(Hash)
          __send__ setter, value
        else
          instance_variable_set "@#{name}", value
        end
      end
    end

  end
end