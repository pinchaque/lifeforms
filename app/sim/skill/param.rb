module Skill
  class Param
    # Parameter definition
    attr_reader :def

    # Current value
    attr_accessor :value

    def initialize(d, v = nil)
      @def = d
      @value = v.nil? ? @def.generate_default : v
    end

    # ID for this parameter, taken from the associated ParamDef
    def id
      @def.id
    end

    # Mutates the parameter value using the distribution
    def mutate
      @value = @def.mutate(@value)
    end

    # Marshals this object into built-in objects
    def marshal
      {
        def: @def.marshal,
        value: @value
      }
    end

    # Unmarshals from an object and returns a new Param object
    def self.unmarshal(obj)
      pd = ParamDef.unmarshal(obj[:def])
      Param.new(pd, obj[:value].to_f)
    end
  end
end