module Wrappi
  # create a new endpoint by setting the basic configuration like verb, path,
  # params, headers, etc
  class Endpoint
    attr_reader :_params, :options
    def initialize(params, options = {})
      @_params = params
      @options = options
    end

    def self.call(*args)
      new(*args).call
    end

    def url
      URI.join(client.domain, path)
    end

    def params
      _params
    end

    def call
      Response.new do
        client.http.send(verb, url, params)
      end
    end
  end
end
