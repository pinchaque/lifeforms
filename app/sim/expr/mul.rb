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

    def mutate_self_real(ctx)
      case [:add, :del, :plus, :div].sample

      when :add
        @exprs << ExprFactory.new(ctx).numop
        self

      when :del
        @exprs.delete_at(Random.rand(0...@exprs.count)) if @exprs.count > 1
        self

      when :div
        ret = Expr::Const.new(1.0)
        while !@exprs.empty?
          ret = Expr::Div.new(@exprs.pop, ret)
        end
        ret

      when :plus
        Expr::Add.new(*@exprs)
      end
    end
  end
end

# Multiplies expressions together
def e_mul(*e)
  Expr::Mul.new(*e)
end