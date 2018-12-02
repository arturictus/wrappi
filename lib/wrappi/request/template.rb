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

      def call
        raise NotImplementedError
      end
    end
  end
end
