module Expr
  # Adds any number of values together
  class Add < BaseMultiple
    def eval(ctx)
      v = 0.0
      @exprs.each { |expr| v += expr.eval(ctx) }
      v
    end

    def op_s
      "+"
    end
  end
end

# Adds expressions together
def e_add(*e)
  Expr::Add.new(*e)
end