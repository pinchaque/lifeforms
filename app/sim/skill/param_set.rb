module Skill
  class ParamSet
    attr_reader :params

    def initialize
      @params = {}
    end

    def add(p)
      raise "Param #{o.id} already exists" if @params.key?(p.id)
      @params[p.id] = p
    end

    def clear
      @params.clear
    end

    def value(sym)
      0.0 # TODO implement
    end
  end
end