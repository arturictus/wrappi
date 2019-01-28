module Wrappi
if defined?(ActiveJob)
  class Async < ActiveJob::Base
    def perform(endpoint_class, params, options)
      @endpoint_class = endpoint_class
      @params = parse(params)
      @options = parse(options)
      return unless endpoint_const
      inst = endpoint_const.new(@params)

      if inst.success?
        inst.perform_async_callback(@options)
      end
    end

    def parse(data)
      return data if data.is_a?(Hash)
      JSON.parse(data)
    rescue
      data
    end

    def endpoint_const
      Class.const_get(@endpoint_class)
    rescue
      Rails.logger.warn("[Wrappi] Unable to find const #{@endpoint_class} for async")
      false
    end
  end
end
end
