module Expr
    # Logical NOT
    class Not < BaseSingle
      def eval(ctx)
        !@expr.eval(ctx)
      end
      
      def to_s
        "!#{@expr.to_s}"
      end

      # Mutates by inverting the NOT and just returning the child.
      def mutate_self_real(ctx)
        @expr
      end  
    end  
end

# Logical NOT
def e_not(e)
  Expr::Not.new(e)
end