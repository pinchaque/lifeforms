module Expr
  # Equality
  class Equal < BaseNumCmp
    def op_s
      "=="
    end

    def cmp(a, b)
      a == b
    end
  end
end

# Numeric equality
def e_equal(e1, e2)
  Expr::Equal.new(e1, e2)
end