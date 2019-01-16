module Wrappi
  class Executer
    class UncalledRequest
      def request
        nil
      end
      alias_method :call, :request

      def called?
        true
      end

      def body
        { "message" => "uncalled response" }
      end

      def success?
        false
      end

      def error?
        true
      end

      def raw_body
        body.to_json
      end

      def uri
        'uncalled_response'
      end

      def status
        100
      end
    end

    def self.call(*args)
      new(*args).call
    end
    attr_reader :endpoint
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def cache
    end

    def around_request
      endpoint.around_request || proc { |res, endpoint| res.call }
    end

    def call
      res = Response.new { Request.new(endpoint).call }
      around_request.call(res, endpoint)
      res.called? ? res : UncalledRequest.new
    end
  end
end
