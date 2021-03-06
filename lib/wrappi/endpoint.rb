require 'wrappi/response'
module Wrappi
  class Endpoint < Miller.base(
    :verb, :client, :path, :default_params,
    :headers, :follow_redirects, :basic_auth,
    :body_type, :retry_options, :cache, #:cache_options,
    :async_callback,
    default_config: {
      verb: :get,
      client: proc { raise 'client not set' }, # TODO: add proper error
      path: proc { raise 'path not defined' }, # TODO: add proper error
      default_params: {},
      headers: proc { client.headers },
      follow_redirects: true,
      body_type: :json,
      cache: proc { options[:cache] },
      # cache_options: {},
      async_callback: proc {},
      basic_auth: proc { client.basic_auth }
    }
  )

    ##############    ClassMethods     ################
    # ============ API class metnods ================
    def self.call(*args)
      new(*args).call
    end

    def self.call!(*args)
      new(*args).call!
    end

    def self.body(*args)
      new(*args).body
    end

    def self.setup(&block)
      instance_exec(&block)
    end

    # =============      Configs     =================
    def self.async_callback(&block)
      @async_callback = block
    end
    
    def self.around_request(&block)
      @around_request = block
    end
    
    def self.retry_if(&block)
      @retry_if = block
    end
    
    def self.cache_options(&block)
      @cache_options = block
    end
    
    # =============      Inheritance     =================
    def self.inherited(subclass)
      super(subclass)
      subclass.instance_variable_set(:@async_callback, @async_callback)
      subclass.instance_variable_set(:@around_request, @around_request)
      subclass.instance_variable_set(:@retry_if, @retry_if)
      subclass.instance_variable_set(:@cache_options, @cache_options)
    end

    # ============== success behaviour   ===================
    # overridable
    def self.success?(request)
      request.code >= 200 && request.code < 300
    end
    #######################################################
    
    attr_reader :input_params, :options
    def initialize(input_params = {}, options = {})
      @input_params = input_params
      @options = options
    end


    def on_success(&block)
      block.call(self) if success?
      self  
    end

    def on_error(&block)
      block.call(self) unless success?
      self
    end

    def call
      return false unless success?
      self
    end
    
    def call!
      raise UnsuccessfulResponse.new(self) unless success?
      self
    end
    
    def response
      @response ||= Executer.call(self)
    end

    def body; response.body end
    def success?; response.success? end
    def status; response.status end
    def error?; !success? end
    def flush; @response = nil end

    def async(async_options = {})
      async_handler.call(self, async_options)
    end

    # overridable
    def consummated_params
      params
    end

    def url
      _url.to_s
    end

    def url_with_params
      return url unless verb == :get
      _url.tap do |u|
        u.query = URI.encode_www_form(consummated_params) if consummated_params.any?
      end.to_s
    end

    def perform_async_callback(async_options = {})
      instance_exec(async_options, &async_callback)
    end

    def cache_key
      # TODO: think headers have to be in the key as well
      @cache_key ||= "[#{verb.to_s.upcase}]##{url}#{params_cache_key}"
    end

    
    def around_request
      self.class.instance_variable_get(:@around_request)
    end

    def retry_if
      self.class.instance_variable_get(:@retry_if)
    end

    def cache_options
      self.class.instance_variable_get(:@cache_options)
    end

    private

    def async_callback
      self.class.instance_variable_get(:@async_callback) || proc {}
    end

    def logger
      client.logger
    end

    # Overridable
    def async_handler
      client.async_handler
    end

    def params_cache_key
      return if params.empty?
      d = Digest::MD5.hexdigest params.to_json
      "?#{d}"
    end

    # URI behaviour
    # example:
    #
    #     URI.join('https://hello.com/foo/bar', '/bin').to_s
    #     => "https://hello.com/bin"
    #
    #     URI.join('https://hello.com/foo/bar', 'bin').to_s
    #     => "https://hello.com/foo/bin"
    #
    #
    #     URI.join('https://hello.com/foo/bar/', '/bin').to_s
    #     => "https://hello.com/bin"
    #
    #     We want this behaviour:
    #     URI.join('https://hello.com/foo/bar/', 'bin').to_s
    #     => "https://hello.com/foo/bar/bin"
    def _url
      URI.join(domain, path_gen.for_uri)
    end

    def domain
      return client.domain if client.domain =~ /\/$/
      "#{client.domain}/"
    end

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
