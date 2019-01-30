module Wrappi
  module AsyncConcern
    def wrappi_perform(endpoint_class, params, options)
      @endpoint_class = endpoint_class
      @params = parse(params)
      @options = parse(options)
      return unless endpoint_const
      inst = endpoint_const.new(@params)
      inst.perform_async_callback(@options)
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
      puts "[Wrappi] Unable to find const #{@endpoint_class} for async"
      false
    end
  end
if defined?(ActiveJob)
  class Async < ActiveJob::Base
    include AsyncConcern
    def perform(*args)
      wrappi_perform(*args)
    end
  end
else
  class Async
    include AsyncConcern
    def self.perform_later(*args)
      puts "Unable to perform async ActiveJob is not installed"
      new().wrappi_perform(*args)
    end
  end
end
end
