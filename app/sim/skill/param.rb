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

    # Marshals this object into a hash
    def marshal_to_h
      {
        def: @def.marshal_to_h,
        value: @value
      }
    end

    # Unmarshals from a hash and returns a new Param object
    def self.unmarshal_from_h(h)
      pd = ParamDef.unmarshal_from_h(h[:def])
      Param.new(pd, h[:value].to_f)
    end
  end
end