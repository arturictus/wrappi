require 'wrappi/response'
module Wrappi
  class Endpoint < Miller.base(
    :verb, :client, :path, :default_params,
    :headers, :follow_redirects, :basic_auth,
    :body_type,
    default_config: {
      verb: :get,
      client: proc { raise 'client not set' }, # TODO: add proper error
      path: proc { raise 'path not defined' }, # TODO: add proper error
      default_params: {},
      headers: proc { client.headers },
      follow_redirects: true,
      body_type: :json
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

    def url
      URI.join("#{client.domain}/", path_gen.path)
    end

    # overridable
    def consummated_params
      params
    end

    # overridable
    def before_request
      true
    end

    # overridable
    def after_request(response)
      true
    end

    def response
      return unless before_request
      @response ||= Response.new do
                      Request.new(self).call
                    end.tap(&:request)
      after_request(@response)
      @response
    end
    alias_method :call, :response

    def body; response.body end
    def success?; response.success? end
    def status; response.status end

    private

    def params
      path_gen.params
    end

    def processed_params
      client.params.merge(default_params.merge(input_params))
    end

    def path_gen
      @path_gen ||= PathGen.new(path, processed_params)
    end


  end
end
