module Wrappi
  # This class is expected to handle all the configurations for your main module
  class Client
    class TimeoutError < StandardError; end
    class JsonParseError < StandardError; end
    class NotAuthorizedAccessError < StandardError; end

    include Fusu::Configurable

    # Not verify example
    # OpenSSL::SSL::SSLContext.new.tap do |ctx|
    #   ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # end
    config_accessor :ssl_context
    config_accessor(:use_ssl_context) { false }
    config_accessor(:logger) { Logger.new(STDOUT) }
    config_accessor(:header) do
      { 'Content-Type' => 'application/json',
        'Accept' => 'application/json'}
    end

    def self.setup
      yield(self)
    end

    def self.domain=(domain)
      @domain = domain
    end

    def self.timeout=(opts)
      @timeout = { write: 3, connect: 3, read: 3 }.merge(opts)
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

    def self.http
      HTTP.timeout(timeout)
    end

    def self.http_with_headers
      http.headers(headers)
    end

    def self.params_with_defaults(params = {})
      if self.use_ssl_context
        fail "[#{self}] Bad configuration: You set `use_ssl_context` but did not provide `ssl_context`" unless self.ssl_context
        params.reverse_merge(ssl_context: self.ssl_context)
      else
        params
      end
    end
  end
end
