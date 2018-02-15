module Wrappi
  module Utils
    def self._eval(inst, val)
      if val.respond_to?(:call)
        inst.instance_exec(&val)
      else
        val
      end
    end

    def self.digg(obj, path, default = {})
    end
  end
end
