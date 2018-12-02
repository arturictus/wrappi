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
                    else
                      raise 'Verb strategy not defined'
                    end
    end

    def call
      @call ||= strategy.call
    end
  end
end
require 'wrappi/request/get'
