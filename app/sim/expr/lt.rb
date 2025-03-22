module Expr
    # Less Than
    class LT < BaseNumCmp
      def op_s
        "<"
      end
  
      def cmp(a, b)
        a < b
      end
    end  
end

# Numeric less than
def e_lt(e1, e2)
  Expr::LT.new(e1, e2)
end