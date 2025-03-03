module Program
  module Expr
      # def marshal        
      # end

      # def unmarshal(str)
      # end

  # Future stuff:
  # Simple math: Plus, Minus, Mult, Div
  # 
    # Expresssion that always returns true
    class True
      def eval(v)
        true
      end

      def to_s
        "true"
      end
    end

    # Logical NOT
    class Not
      def initialize(expr)
        @expr = expr
      end

      def eval(v)
        !@expr.eval(v)
      end
      
      def to_s
        "!#{@expr.to_s}"
      end
    end

    # Logical AND
    class And
      def initialize(*exprs)
        @exprs = exprs
      end

      def eval(v)
        @exprs.all? { |expr| expr.eval(v) }
      end
      
      def to_s
        ret = @exprs.map{ |expr| "#{expr.to_s}" }.join(" && ")
        (@exprs.count > 1) ? "(#{ret})" : ret
      end
    end

    # Logical OR
    class Or
      def initialize(*exprs)
        @exprs = exprs
      end

      def eval(v)
        @exprs.any? { |expr| expr.eval(v) }
      end
      
      def to_s
        ret = @exprs.map{ |expr| "#{expr.to_s}" }.join(" || ")
        (@exprs.count > 1) ? "(#{ret})" : ret
      end
    end

    # Base class for numeric comparisons
    class NumCmp
      def initialize(e1, e2, op_s)
        @e1 = e1
        @e2 = e2
        @op_s = op_s
      end
      
      def to_s
        "(#{@e1} #{@op_s} #{@e2})"
      end

      def get_val(v, str)
        v[str.to_sym].to_f
      end

      def eval(v)
        cmp(get_val(v, @e1), get_val(v, @e2))
      end
    end

    # Equality
    class Equal < NumCmp
      def initialize(e1, e2)
        super(e1, e2, "==")
      end

      def cmp(a, b)
        a == b
      end
    end
  
    # Less Than
    class LT < NumCmp
      def initialize(e1, e2)
        super(e1, e2, "<")
      end

      def cmp(a, b)
        a < b
      end
    end

    # Less Than or Equal
    class LTE < NumCmp
      def initialize(e1, e2)
        super(e1, e2, "<=")
      end

      def cmp(a, b)
        a <= b
      end
    end

    # Greater Than
    class GT < NumCmp
      def initialize(e1, e2)
        super(e1, e2, ">")
      end

      def cmp(a, b)
        a > b
      end
    end

    # Greater Than or Equal
    class GTE < NumCmp
      def initialize(e1, e2)
        super(e1, e2, ">=")
      end

      def cmp(a, b)
        a >= b
      end
    end
  end

  # The below functions are helpers to create the above classes. This is most
  # useful for testing and hard-coded behaviors.

  # Constant TRUE
  def e_true
    Expr::True.new
  end

  # Logical NOT
  def e_not(e)
    Expr::Not.new(e)
  end

  # Logical AND
  def e_and(*e)
    Expr::And.new(*e)
  end

  # Logical OR
  def e_or(*e)
    Expr::Or.new(*e)
  end

  # Numeric equality
  def e_equal(e1, e2)
    Expr::Equal.new(e1, e2)
  end

  # Numeric less than
  def e_lt(e1, e2)
    Expr::LT.new(e1, e2)
  end

  # Numeric less than or equal to
  def e_lte(e1, e2)
    Expr::LTE.new(e1, e2)
  end

  # Numeric greater than
  def e_gt(e1, e2)
    Expr::GT.new(e1, e2)
  end

  # Numeric greater than or equal to
  def e_gte(e1, e2)
    Expr::GTE.new(e1, e2)
  end
end