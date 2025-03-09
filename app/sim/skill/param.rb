module Skill
  class Param
    # Parameter definition
    attr_accessor :def

    # Current value
    attr_accessor :value

    # Mutates the parameter value using the distribution
    def mutate
      @value = @def.mutate(@value)
    end
  end
end