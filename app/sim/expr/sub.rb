module Expr
  # Subtracts one value from another
  class Sub < BaseDuo
    def eval(ctx)
      @expr1.eval(ctx) - @expr2.eval(ctx)
    end

    def op_s
      "-"
    end

    def mutate_self_real(ctx)
      case [:add, :div, :mul].sample

      when :add
        Expr::Add.new(@expr1, @expr2)

      when :div
        Expr::Div.new(@expr1, @expr2)

      when :mul
        Expr::Mul.new(@expr1, @expr2)
      end
    end
  end
end

# Subtracts one expression from another
def e_sub(e1, e2)
  Expr::Sub.new(e1, e2)
end