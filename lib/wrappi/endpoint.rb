require 'wrappi/response'
module Wrappi
  # TODO
  # - basic auth
  # - add headers
  class Endpoint < Miller.base(
    :verb, :client, :path, :default_params,
    :headers, :follow_redirects, :basic_auth,
    default_config: {
      verb: :get,
      client: proc { raise 'client not set' }, # TODO: add proper error
      path: proc { raise 'path not defined' }, # TODO: add proper error
      default_params: {},
      headers: proc { client.headers },
      follow_redirects: true
    }
  )
    attr_reader :input_params, :options
    def initialize(input_params = {}, options = {})
      @input_params = input_params
      @options = options
    end

    def self.call(*args)
      new(*args).call
    end

    def path_gen
      @path_gen ||= PathGen.new(path, processed_params)
    end

    def url
      URI.join(client.domain, path_gen.path)
    end

    # TODO find a way to be able to modify params with a callback
    # can be overriding a method or adding a config
    def params
      path_gen.params
    end

    def processed_params
      default_params.merge(input_params)
    end

    def response
      @response ||= Response.new do
                      Request.new(self).call
                    end
    end
    alias_method :call, :response

    def body; response.body end
    def success?; response.success? end
    def status; response.status end
  end
end
