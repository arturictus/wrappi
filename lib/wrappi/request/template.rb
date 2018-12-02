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
        # TODO: build here the http instead of in client.
        # that will allow us to override the client default configurations
        # - basic auth https://github.com/httprb/http/wiki/Authorization-Header
        # - headers
        # - follow redirects https://github.com/httprb/http/wiki/Redirects
        client.http
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
