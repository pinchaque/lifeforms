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

    def mutate_self_real(ctx)
      case [:add, :del, :mul, :sub].sample

      when :add
        @exprs << ExprFactory.new(ctx).numop
        self

      when :del
        @exprs.delete_at(Random.rand(0...@exprs.count)) if @exprs.count > 1
        self

      when :sub
        ret = Expr::Const.new(0.0)
        while !@exprs.empty?
          ret = Expr::Sub.new(@exprs.pop, ret)
        end
        ret

      when :mul
        Expr::Mul.new(*@exprs)
      end
    end
  end
end

# Adds expressions together
def e_add(*e)
  Expr::Add.new(*e)
end