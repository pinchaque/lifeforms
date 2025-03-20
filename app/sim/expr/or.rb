module Expr
    # Logical OR
    class Or < BaseMultiple
      def eval(ctx)
        @exprs.any? { |expr| expr.eval(ctx) }
      end
  
      def op_s
        "||"
      end
    end  
end

# Logical OR
def e_or(*e)
  Expr::Or.new(*e)
end