module Program
  module Expr
      # def marshal        
      # end

      # def unmarshal(str)
      # end

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

    # Numeric Equality
    class Equal
      def initialize(e1, e2)
        @e1 = e1
        @e2 = e2
      end

      def eval(v)
        v[@e1.to_sym] == v[@e2.to_sym]
      end
      
      def to_s
        "#{@e1} == #{@e2}"
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
end