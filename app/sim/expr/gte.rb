module Expr
  # Greater Than or Equal
  class GTE < BaseNumCmp
    def op_s
      ">="
    end

    def cmp(a, b)
      a >= b
    end
  end
end

# Numeric greater than or equal to
def e_gte(e1, e2)
  Expr::GTE.new(e1, e2)
end