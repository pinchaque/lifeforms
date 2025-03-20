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
  end  
end

# Constant value
def e_const(v)
  Expr::Const.new(v)
end