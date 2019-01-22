module Wrappi
  class Request
    attr_reader :endpoint
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def verb
      endpoint.verb
    end

    def strategy
      @strategy ||= case verb
                    when :get
                      Get.new(endpoint)
                    when :post, :delete, :put
                      WithBody.new(endpoint)
                    else
                      raise 'Verb strategy not defined'
                    end
    end

    def call
      @call ||= strategy.call
    end
    alias_method :http, :call

    def to_h
      @to_h ||= {
        raw_body: http.raw_body,
        code: http.code,
        uri: http.uri
      }
    end
  end
end
require 'wrappi/request/template'
require 'wrappi/request/get'
require 'wrappi/request/with_body'
