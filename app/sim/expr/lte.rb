module Expr
    # Less Than or Equal
    class LTE < BaseNumCmp
      def op_s
        "<="
      end
  
      def cmp(a, b)
        a <= b
      end
    end  
end

# Numeric less than or equal to
def e_lte(e1, e2)
  Expr::LTE.new(e1, e2)
end