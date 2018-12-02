module Wrappi
  class Request
    class Template
      attr_reader :endpoint
      def initialize(endpoint)
        @endpoint = endpoint
      end

      def client
        endpoint.client
      end

      def params
        endpoint.params
      end

      def url
        endpoint.url
      end

      def http
        h = HTTP.timeout(client.timeout)
                .headers(endpoint.headers)
        h = h.follow() if endpoint.follow_redirects
        h = h.basic_auth(endpoint.basic_auth) if endpoint.basic_auth
        h
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
