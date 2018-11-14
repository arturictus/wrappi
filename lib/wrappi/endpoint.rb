require 'wrappi/endpoint/dsl'
module Wrappi
  # create a new endpoint by setting the basic configuration like verb, path,
  # params, headers, etc
  class Endpoint
    include InstConfig

    def self.inherited(subclass)
      subclass.extend Endpoint::KlassDSL
      return unless self < Wrappi::Endpoint
      unless dsl.config.empty?
        subclass._set_config_from_inheritance(config)
      end
    end

    attr_reader :params, :options
    def initialize(params = {}, options = {})
      @params = params
      @options = options
    end

    def self.call(*args)
      new(*args).call
    end

    def metadata
      @metadata = Wrappi::Metadata.new(self)
    end

    def url
      URI.join(client.domain, path)
    end

    def call
      Response.new(self) do
        client.http.send(verb, url, params)
      end
    end
  end
end
require 'wrappi/endpoint/dsl'
