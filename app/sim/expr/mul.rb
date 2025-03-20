module Expr
  # Multiplies values together
  class Mul < BaseMultiple
    def eval(ctx)
      v = 1.0
      @exprs.each { |expr| v *= expr.eval(ctx) }
      v
    end
    
    def op_s
      "*"
    end
  end
end

# Multiplies expressions together
def e_mul(*e)
  Expr::Mul.new(*e)
end