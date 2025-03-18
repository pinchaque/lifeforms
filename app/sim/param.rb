class Param
  # Parameter definition
  attr_reader :def

  # Current value
  attr_reader :value

  def initialize(d, v = nil)
    @def = d
    @value = v.nil? ? @def.generate_default : v
  end

  # ID for this parameter, taken from the associated ParamDef
  def id
    @def.id
  end

  # Sets the value of the parameter and applies the ParamDef's constraints
  # to ensure an allowable value.
  def set(v)
    @value = @def.constrain(v)
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