module Wrappi
  class Config < Hash
    def digg(elems, default = nil)
      if self.respond_to?(:dig)
        dig(elems) || default
      else
        _dig(elems) || default
      end
    end

    def _dig(*args)
      args.inject(self) do |output, k|
        break unless output.respond_to?(:[])
        output.send(:[], k)
      end
    end
  end
end
