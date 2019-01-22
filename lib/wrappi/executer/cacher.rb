module Wrappi
  class Executer
    class Cacher
      attr_reader :endpoint
      def initialize(endpoint)
        @endpoint = endpoint
      end

      def get_cached
        cached = cache.read(cache_key)
        return CachedResponse.new(cached) if cached
        response = yield
        cache.write(cache_key, response.to_h) if response.success?
        response
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

    end
  end
end
