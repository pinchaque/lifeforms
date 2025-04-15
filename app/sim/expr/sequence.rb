module Expr
  # Represents a sequence of expressions that are executed in order
  class Sequence < BaseMultiple
    def op_s
      "->"
    end

    # Executes sequence of expressions in order, returning the last one as the
    # result
    def eval(ctx)
      @exprs.map { |st| st.eval(ctx) }.last
    end

    def mutate_real(ctx)
      case [:add, :del, :shuffle, :if].sample

      when :add
        @exprs << ExprFactory.new(ctx).statement
        self

      when :del
        @exprs.delete_at(Random.rand(0...@exprs.count)) if @exprs.count > 1
        self

      when :shuffle
        @exprs.shuffle!
        self

      when :if
        Expr::If.new(ExprFactory.new(ctx).bool, self)
      end
    end
  end
end

# Sequence of expressions
def e_seq(*exprs)
  Expr::Sequence.new(*exprs)
end