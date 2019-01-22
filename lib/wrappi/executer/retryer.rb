module Wrappi
  class Executer
    class Retryer
      class RetryError < StandardError; end
      attr_reader :endpoint
      def initialize(endpoint)
        @endpoint = endpoint
      end

      def call
        if retry?
          Retryable.retryable(retry_options) do
            res = yield
            raise RetryError if retry_if.call(res, endpoint)
            res
          end
        else
          yield
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

      def retry?
        !!endpoint.retry_if
      end

      def retry_if
        endpoint.retry_if
      end
    end
  end
end
