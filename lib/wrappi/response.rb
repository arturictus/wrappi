module Wrappi
  class Response
    attr_reader :request
    alias_method :call, :request

    def initialize(endpoint, &block)
      @request = block.call
    end

    def body
      @body ||= JSON[call.body.to_s]
    end

    def success?
      request.status < 300 && request.status >= 200
    end

    def method_missing(method_name, *arguments, &block)
      if request.respond_to?(method_name)
        request.send(method_name, *arguments, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      request.respond_to?(method_name) || super
    end
  end
end
