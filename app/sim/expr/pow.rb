module Expr
  # Raises one value to the power of another
  class Pow < BaseDuo
    def eval(ctx)
      @expr1.eval(ctx) ** @expr2.eval(ctx)
    end

    def op_s
      "^"
    end
  end
end

# Raises one expression to the power of another
def e_pow(e_base, e_exp)
  Expr::Pow.new(e_base, e_exp)
end