#require 'wrappi/endpoint/dsl'
module Wrappi
  # create a new endpoint by setting the basic configuration like verb, path,
  # params, headers, etc
  class Endpoint < Miller.base(:verb, :client, :path, :default_params,
      verb: :get,
      client: proc { raise 'client not set' },
      path: proc { raise 'path not defined' },
      default_params: {}
  )

    attr_reader :input_params, :options
    def initialize(input_params = {}, options = {})
      @input_params = input_params
      @options = options
    end

    def self.call(*args)
      new(*args).call
    end

    def url
      URI.join(client.domain, path)
    end

    # TODO find a way to be able to modify params with a callback
    # can be overriding a method or adding a config
    def params
      processed_params
    end

    def processed_params
      default_params.merge(input_params)
    end

    def call
      Response.new(self) do
        client.http.send(verb, url, params)
      end
    end
  end
end