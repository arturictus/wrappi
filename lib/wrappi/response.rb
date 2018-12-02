module Wrappi
  # Wrapper around HTTP::Response
  # check documentation at:
  # https://github.com/httprb/http/wiki/Response-Handling
  class Response
    attr_reader :block

    def initialize(&block)
      @block = block
    end

    def request
      @request ||= block.call
    end
    alias_method :call, :request

    def body
      @body ||= request.parse
    end

    def success?
      request.code < 300 && request.code >= 200
    end

    def error?
      !success?
    end

    def raw_body
      request.to_s
    end

    def uri
      request.uri.to_s
    end

    def status
      request.code
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
