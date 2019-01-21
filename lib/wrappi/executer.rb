module Wrappi
  class Executer

    class RetryError < StandardError; end

    def self.call(*args)
      new(*args).call
    end
    attr_reader :endpoint
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def call
      if cache?
        get_cached
      else
        request_with_retry
      end
    end

    private

    def get_cached
      if cached = cache.read(cache_key)
        CachedResponse.new(cached)
      else
        response = request_with_retry
        if r.success?
          cache.write(cache_key, r.request.to_h)
        end
        response
      end
    end

    def cache?
      endpoint.client.cache && endpoint.cache && cache_allowed_verb?
    end

    def cache_allowed_verb?
      if [:get, :post].include?(endpoint.verb)
        true
      else
        puts "Cache is only available to no side effect requests: :get and :post" # TODO: make a warning
        false
      end
    end

    def cache
      endpoint.client.cache
    end

    def cache_key
      endpoint.cache_key
    end

    def request_with_retry
      if retry?
        Retryable.retryable(retry_options) do
          res = make_request
          raise RetryError if retry_if.call(res, endpoint)
          res
        end
      else
        make_request
      end
    end

    def retry_options
      default = { tries: 3, on: [RetryError] }
      if endpoint.retry_options
        end_opts = endpoint.retry_options.dup
        {}.tap do |h|
          h[:tries] = end_opts[:tries] || default[:tries]
          if on = end_opts.delete(:on)
            h[:on] = default[:on] + Fusu::Array.wrap(on)
          end
        end.merge(end_opts)
      else
        default
      end
    end

    def around_request
      endpoint.around_request || proc { |res, endpoint| res.call }
    end

    def retry?
      !!endpoint.retry_if
    end

    def retry_if
      endpoint.retry_if
    end

    def make_request
      res = Response.new { Request.new(endpoint).call }
      around_request.call(res, endpoint)
      res.called? ? res : UncalledRequest.new
    end
  end
end
