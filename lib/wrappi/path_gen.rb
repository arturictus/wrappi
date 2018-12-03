module Wrappi
  # TODO: REFACTOR!!
  class PathGen

    attr_reader :input_path, :input_params
    def initialize(input_path, input_params)
      @input_path = input_path
      @input_params = input_params
      @interpolable = input_path =~ /:\w+/
    end

    def compiled_path
      return input_path unless interpolable?
      URI.escape(new_sections.join('/'))
    end
    alias_method :path, :compiled_path

    def processed_params
      return input_params unless interpolable?
      input_params.reject{ |k, v| keys_in_params.include?(k) }
    end
    alias_method :params, :processed_params

    private

    def interpolable?
      @interpolable
    end

    def new_sections
      sections.map do |e|
        if e =~ /:\w+/
          i = e[1..-1]
          input_params.fetch(i.to_sym)
        else
          e
        end
      end
    end
    def sections
      input_path.split("/")
    end
    def keys_in_params
      interpolations.map do |k|
        i = k[1..-1]
        i.to_sym
      end
    end
    def interpolations
      input_path.scan(/:\w+/)
    end
  end
end
