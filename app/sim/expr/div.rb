module Expr
  # Divs one value by another
  class Div < BaseDuo
    def eval(ctx)
      e2 = @expr2.eval(ctx)
      (e2 == 0.0) ? 0.0 : (@expr1.eval(ctx) / e2)
    end

    def op_s
      "/"
    end

    def mutate_self_real(ctx)
      case [:add, :mul, :sub].sample

      when :add
        Expr::Add.new(@expr1, @expr2)

      when :sub
        Expr::Sub.new(@expr1, @expr2)

      when :mul
        Expr::Mul.new(@expr1, @expr2)
      end
    end
  end
end

# Divs one expression by another
def e_div(e1, e2)
  Expr::Div.new(e1, e2)
end