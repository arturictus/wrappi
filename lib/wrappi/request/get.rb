module Wrappi
  class Request
    class Get
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

      def call
        client.http.get(url, params: params)
      end
    end
  end
end
