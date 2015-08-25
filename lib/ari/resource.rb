# TODO use variable names with underscores
module Ari
  class Resource < Model

    def client(options = {})
      return @client if @client
      self.class.client(options)
    end

    def self.client(options = {})  
      client = options.fetch(:client, nil)
      return client if client
      Ari.client
    end

    def add_listener(type, params = {}, &block)
      client.class.instance_listeners[type.to_sym] ||= []
      unless client.class.instance_listeners[type.to_sym].any? { |l| l.id == self.id }
        client.class.instance_listeners[type.to_sym] << self
      end
      client.add_listener "#{type}-#{self.id}", params, &block
    end
    alias_method :on, :add_listener

    def remove_listener(type)
      client.class.instance_listeners[type.to_sym] ||= []
      client.class.instance_listeners[type].delete_if { |i| i.id == self.id }
      client.remove_listener "#{type}-#{self.id}"
    end
    alias_method :off, :remove_listener

    def remove_all_listeners!
      client.class.instance_listeners.each do |type, _|
        remove_listener type
      end
    end
    alias_method :off_all!, :remove_all_listeners!

  end
end
