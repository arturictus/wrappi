module Wrappi
  class CachedResponse
    def initialize(blob)
      @blob = blob
    end

    private

    def blob; @blob end
  end
end
