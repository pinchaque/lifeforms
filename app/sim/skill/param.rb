module Skill
  class Param
    # Parameter definition
    attr_reader :def

    # Current value
    attr_accessor :value

    def initialize(d)
      @def = d
      @value = @def.generate_default
    end

    # Mutates the parameter value using the distribution
    def mutate
      @value = @def.mutate(@value)
    end
  end
end