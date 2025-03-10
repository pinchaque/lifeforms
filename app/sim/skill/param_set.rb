module Skill
  class ParamSet
    attr_reader :params

    # Initializes with an empty ParamSet
    def initialize
      @params = {}
    end

    # Adds a parameter to this ParamSet
    def add(p)
      raise "Param #{o.id} already exists" if @params.key?(p.id)
      @params[p.id] = p
    end

    # Returns number of Params in this ParamSet
    def count
      @params.count
    end

    # Removes all parameters
    def clear
      @params.clear
    end

    # Returns true if this ParamSet has the parameter with the given id, false
    # otherwise
    def include?(id)
      @params.key?(id)
    end

    # Returns the value for parameter id, or default if it doesn't exist
    def value(id, default = nil)
       include?(id) ? @params[id].value : default
    end
  end
end