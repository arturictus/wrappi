require "wrappi/version"
require 'http'
require 'fusu'
require 'miller'
require 'retryable'

module Wrappi
  class Error < StandardError; end
  class TimeoutError < Error; end
  class JsonParseError < Error; end
  class ConnectionError < Error; end
  class RequestError < Error; end
  class ResponseError < Error; end
  class StateError < ResponseError; end
  class TimeoutError < Error; end
  class HeaderError < Error; end

  def self.errors
    [
      Error,
      TimeoutError,
      JsonParseError,
      ConnectionError,
      RequestError,
      ResponseError,
      StateError,
      TimeoutError,
      HeaderError
    ]
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
