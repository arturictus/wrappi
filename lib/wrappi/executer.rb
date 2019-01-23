module Wrappi
  class Executer

    def self.call(*args)
      new(*args).call
    end

    attr_reader :endpoint, :retryer, :cacher
    def initialize(endpoint)
      @endpoint = endpoint
      @retryer = Retryer.new(endpoint)
      @cacher = Cacher.new(endpoint)
    end

    def call
      if cache?
        cacher.call do
          request_with_retry
        end
      else
        request_with_retry
      end
    end

    private

    def cache?
      cacher.cache?
    end

    def request_with_retry
      retryer.call do
        make_request
      end
    end

    def around_request
      endpoint.around_request || proc { |res, endpoint| res.call }
    end

    def make_request
      res = Response.new { Request.new(endpoint).call }
      around_request.call(res, endpoint)
      res.called? ? res : UncalledRequest.new
    end
  end
end
require 'wrappi/executer/retryer'
require 'wrappi/executer/cacher'
