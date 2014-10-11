module Ari
  class ListResource

    def initialize(client, resource_klass)
      @client = client
      @resource_klass = resource_klass
    end

    private

    def method_missing(method, *args, &block)
      if @resource_klass.respond_to? method
        options = args.first
        options ||= {}
        options.merge!(client: @client)
        @resource_klass.send(method, options, &block)
      else
        super
      end
    end

  end
end
