module Wrappi
  class Endpoint
    module KlassDSL
      def method_missing(method, *args, &block)
        if dsl.respond_to?(method)
          dsl.send(method, *args, &block)
        else
          super
        end
      end

      def dsl
        @dsl ||= DSL.new
      end

      def config
        dsl.config
      end

      def _set_config_from_inheritance(attrs)
        dsl._set_config(attrs.dup)
      end
    end

    class DSL
      SETUPS = [:verb, :client, :path, :default_params]
      attr_reader :config

      def initialize
        @config = {
          verb: :get,
          client: proc { raise 'client not set' },
          path: proc { raise 'path not defined' },
        }
      end

      SETUPS.each do |m|
        define_method(m) do |arg = nil, &block|
          @config[m] = block || arg
        end
      end

      def config
        @config
      end

      def _set_config(attrs)
        @config = attrs
      end
    end

    module InstConfig
      def config
        self.class.config
      end
      DSL::SETUPS.each do |m|
        define_method(m) do
          extract_config(config.fetch(m))
        end
      end

      def extract_config(setting)
        if setting.respond_to?(:call)
          instance_exec(&setting)
        else
          setting
        end
      end
    end
  end
end
