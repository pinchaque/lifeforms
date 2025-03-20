module Expr
    # Greater Than
    class GT < BaseNumCmp
      def op_s
        ">"
      end
  
      def cmp(a, b)
        a > b
      end
    end  
end

# Numeric greater than
def e_gt(e1, e2)
  Expr::GT.new(e1, e2)
end