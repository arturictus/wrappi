module Wrappi
  class Metadata
    attr_reader :endpoint, :config
    def initialize(endpoint)
      @endpoint = endpoint
      @config = endpoint.class.config
    end

    def url
      if config[:url]
        _eval(config[:url])
      else
        URI.join(_eval(config[:domain]), _eval(config[:path])).to_s
      end
    end

    def headers
      api = config[:api] ? _eval(config[:api][:headers]) : {}
      base = _eval(config[:headers]) || {}
      mix = api.merge(base)
      config[:added_headers].to_h.each do |h|
        mix[h[0]] = _eval(h[1])
      end
      mix
    end

    def verb
      _eval(config[:verb])
    end

    private

    def _eval(val)
      if val.respond_to?(:call)
        endpoint.instance_exec(&val)
      else
        val
      end
    end
  end
end
