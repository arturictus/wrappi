module Wrappi
  class CachedResponse

    # TODO: has to behave like Response
    def initialize(cached_data)
      @cached_data = Fusu::HashWithIndifferentAccess.new(cached_data)
    end

    def success?
      true
    end

    private

    def cached_data; @cached_data end
  end
end
