require 'logger'
module Wrappi
  # This class is expected to handle all the configurations for your main module
  class Client < Miller.base(
    :ssl_context, :use_ssl_context, :logger,
    :headers, :domain,
    default_config: {
      domain: -> { fail "[#{self.class}] Bad configuration: you must set the `domain` config" },
      header: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'},
      logger: -> { Logger.new(STDOUT) },
      use_ssl_context: false
    }
  )
    class TimeoutError < StandardError; end
    class JsonParseError < StandardError; end
    class NotAuthorizedAccessError < StandardError; end

    # Not verify example
    # OpenSSL::SSL::SSLContext.new.tap do |ctx|
    #   ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # end

    def self.setup
      yield(self)
    end

    def self.timeout=(opts)
      @timeout = { write: 3, connect: 3, read: 3 }.merge(opts)
    end

    def self.timeout
      return @timeout if defined?(@timeout)
      self.timeout = {}
      @timeout
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

    # def self.params_with_defaults(params = {})
    #   if self.use_ssl_context
    #     fail "[#{self}] Bad configuration: You set `use_ssl_context` but did not provide `ssl_context`" unless self.ssl_context
    #     params.reverse_merge(ssl_context: self.ssl_context)
    #   else
    #     params
    #   end
    # end
  end
end
