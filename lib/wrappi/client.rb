require 'logger'
module Wrappi
  # This class is expected to handle all the configurations for your main module
  class Client
    include Fusu::Configurable

    # Not verify example
    # OpenSSL::SSL::SSLContext.new.tap do |ctx|
    #   ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # end
    config_accessor :ssl_context
    config_accessor(:use_ssl_context) { false }
    config_accessor(:logger) { Logger.new(STDOUT) }
    config_accessor(:headers) do
      { 'Content-Type' => 'application/json',
        'Accept' => 'application/json' }
    end
    config_accessor(:params) { {} }
    config_accessor(:cache)
    config_accessor(:async_handler) { AsyncHandler }

    def self.setup
      yield(self)
    end

    def self.domain=(domain)
      @domain = domain
    end

    def self.timeout=(opts)
      @timeout = { write: 9, connect: 9, read: 9 }.merge(opts)
    end

    def self.timeout
      return @timeout if defined?(@timeout)
      self.timeout = {}
      @timeout
    end

    def self.domain
      fail "[#{self.class}] Bad configuration: you must set the `domain` config" unless @domain
      @domain
    end

    def self.errors
      [
        TimeoutError,
        JsonParseError,
        NotAuthorizedAccessError
      ]
    end

    def self.root
      Pathname.new(File.expand_path('../../', __FILE__))
    end

  #   def self.params_with_defaults(params = {})
  #     if self.use_ssl_context
  #       fail "[#{self}] Bad configuration: You set `use_ssl_context` but did not provide `ssl_context`" unless self.ssl_context
  #       params.reverse_merge(ssl_context: self.ssl_context)
  #     else
  #       params
  #     end
  #   end
  end
end
