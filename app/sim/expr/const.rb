require 'rubystats'

module Expr
  # Represents a constant numeric value
  class Const < Base
    def initialize(v)
      @value = v.to_f
    end

    def eval(ctx)
      @value
    end

    def to_s
      @value.to_s
    end

    def marshal
      marshal_value(@value)
    end

    def self.unmarshal_value(v)
      self.new(v.to_f)
    end

    # Mutates the value of this constant following a normal distribution
    # and maintaining the number's sign.
    def mutate_real(lf)
      stddev = (0.12 * @value).abs
      v = Rubystats::NormalDistribution.new(@value, stddev).rng
      v = 0.0 if ((@value > 0.0 && v < 0.0) || (@value < 0.0 && v > 0.0))
      @value = v
    end
  end  
end

# Constant value
def e_const(v)
  Expr::Const.new(v)
end