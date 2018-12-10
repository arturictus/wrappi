module Wrappi
  class Request
    class BodyType < Template
      def call
        http.send(verb, url, json: params)
      end
    end
  end
end
