module Expr
    # Logical NOT
    class Not < BaseSingle
      def eval(ctx)
        !@expr.eval(ctx)
      end
      
      def to_s
        "!#{@expr.to_s}"
      end
    end  
end

# Logical NOT
def e_not(e)
  Expr::Not.new(e)
end