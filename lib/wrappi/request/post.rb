module Wrappi
  class Request
    class Post < Template
      def call
        http.post(url, json: params)
      end
    end
  end
end
