module Ari
  class ServerError < StandardError
    attr_reader :code
    def initialize(code)
      @code = code
    end
  end
end
