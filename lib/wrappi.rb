require "wrappi/version"
require 'http'
require 'fusu'
require 'miller'
require 'retryable'

module Wrappi
  class TimeoutError < StandardError; end
  class NotAuthorizedAccessError < StandardError; end
  class JsonParseError < StandardError; end
  class UnsuccessfulResponse < StandardError
    def initialize(endpoint)
      @endpoint = endpoint
      @output = StringIO.new.tap { |s| s.puts "" }
      super(_message)
    end

    def _message
      @endpoint.response.to_h.each do |k, v|
        @output.puts "    #{k}: #{v}"
      end
      @output.string
    end
  end
end

require 'wrappi/async_job'
require 'wrappi/async_handler'
require 'wrappi/client'
require 'wrappi/executer'
require 'wrappi/endpoint'
require 'wrappi/request'
require 'wrappi/path_gen'
require 'wrappi/uncalled_request'
require 'wrappi/cached_response'
