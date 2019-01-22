module Wrappi
  class CachedResponse
    # input is a <Response>.to_h
    # Example input
    # {
    #   raw_body: '{"foo": "bar"}',
    #   code: 200,
    #   uri: "http://hello.com",
    #   success: true
    # }
    def initialize(cached_data)
      @cached_data = Fusu::HashWithIndifferentAccess.new(cached_data)
    end

    def call
      self
    end

    def called?
      false
    end

    def body
      @body ||= JSON.parse(cached_data[:raw_body])
    end

    def success?
      cached_data[:success]
    end

    def error?
      !success?
    end

    def raw_body
      cached_data[:raw_body]
    end

    def uri
      cached_data[:uri]
    end

    def status
      cached_data[:code]
    end
    alias_method :status_code, :status

    private

    def cached_data; @cached_data end
  end
end
