module Wrappi
  class Request
    class WithBody < Template
      def call
        http.send(verb, url, body)
      end

      private

      def body
        { body_type.to_sym => params }
      end

      def body_type
        case endpoint.body_type
        when :json, :form, :body
          endpoint.body_type
        else
          raise "body_type not recognized"
        end
      end
    end
  end
end
