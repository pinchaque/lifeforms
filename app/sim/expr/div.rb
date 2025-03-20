module Expr
  # Divs one value by another
  class Div < BaseDuo
    def eval(ctx)
      @expr1.eval(ctx) / @expr2.eval(ctx)
    end

    def op_s
      "/"
    end
  end
end

# Divs one expression by another
def e_div(e1, e2)
  Expr::Div.new(e1, e2)
end