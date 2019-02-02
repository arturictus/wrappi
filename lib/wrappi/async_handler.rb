module Wrappi
  class AsyncHandler
    def self.call(*args)
      new(*args).call
    end
    attr_reader :endpoint, :options
    def initialize(endpoint, options)
      @endpoint = endpoint
      @options = options
    end

    def call
      AsyncJob.set((options[:set] || {}))
           .perform_later(endpoint.class.to_s, { params: endpoint.input_params, options: endpoint.options }, options)
    end
  end
end
