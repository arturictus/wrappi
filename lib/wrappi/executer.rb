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
    class RetryError < StandardError; end

    def self.call(*args)
      new(*args).call
    end
    attr_reader :endpoint
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def call
      request_with_retry
    end

    private

    def cache?
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
