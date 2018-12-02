module Wrappi
  class Request
    class Post < Template
      def call
        client.http.post(url, json: params)
      end
    end
  end
end
