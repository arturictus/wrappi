module Wrappi
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
end
