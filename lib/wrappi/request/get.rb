module Wrappi
  class Request
    class Get < Template
      def call
        client.http.get(url, params: params)
      end
    end
  end
end
