module Expr
  # Logical AND
  class And < BaseMultiple
    def eval(ctx)
      @exprs.all? { |expr| expr.eval(ctx) }
    end

    def op_s
      "&&"
    end

    def mutate_self_real(ctx)
      case [:add, :del, :not, :or].sample

      when :add
        @exprs << ExprFactory.new(ctx).bool
        self

      when :del
        @exprs.delete_at(Random.rand(0...@exprs.count)) if @exprs.count > 1
        self

      when :not
        Expr::Not.new(self)

      when :or
        Expr::Or.new(*@exprs)
      end
    end
  end  
end

# Logical AND
def e_and(*e)
  Expr::And.new(*e)
end