module Expr
  # Logical OR
  class Or < BaseMultiple
    def eval(ctx)
      @exprs.any? { |expr| expr.eval(ctx) }
    end

    def op_s
      "||"
    end


    def mutate_self_real(ctx)
      case [:add, :del, :not, :and].sample

      when :add
        @exprs << ExprFactory.new(ctx).bool
        self

      when :del
        @exprs.delete_at(Random.rand(0...@exprs.count)) if @exprs.count > 1
        self

      when :not
        Expr::Not.new(self)

      when :and
        Expr::And.new(*@exprs)
      end
    end
  end
end

# Logical OR
def e_or(*e)
  Expr::Or.new(*e)
end