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
    end  
end

# Sequence of expressions
def e_seq(*exprs)
  Expr::Sequence.new(*exprs)
end