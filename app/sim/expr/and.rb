module Expr
    # Logical AND
    class And < BaseMultiple
      def eval(ctx)
        @exprs.all? { |expr| expr.eval(ctx) }
      end
  
      def op_s
        "&&"
      end
    end  
end

# Logical AND
def e_and(*e)
  Expr::And.new(*e)
end