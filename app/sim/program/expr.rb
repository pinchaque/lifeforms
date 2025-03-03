module Program
  module Expr
    # Interface parent class for all expressions
    class Base
      def eval(v)
        raise "Invalid call to Expr::Base.eval()"
      end
      
      def to_s
        raise "Invalid call to Expr::Base.to_s()"
      end

      # def marshal        
      # end

      # def unmarshal(str)
      # end
    end

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
    class Not < Base
      attr_accessor :expr

      def initialize(expr)
        @expr = expr
      end

      def eval(v)
        !expr.eval(v)
      end
      
      def to_s
        "!(#{expr.to_s})"
      end
    end

    # Logical AND
    class And < Base
      attr_accessor :exprs

      def initialize(*exprs)
        @exprs = exprs
      end

      def eval(v)
        exprs.all? { |expr| expr.eval(v) }
      end
      
      def to_s
        exprs.map{ |expr| "(#{expr.to_s})" }.join(" && ")
      end
    end

    # Logical OR
    class Or < Base
      attr_accessor :exprs

      def initialize(*exprs)
        @exprs = exprs
      end

      def eval(v)
        exprs.any? { |expr| expr.eval(v) }
      end
      
      def to_s
        exprs.map{ |expr| "(#{expr.to_s})" }.join(" || ")
      end
    end
  end

  # # Constant TRUE
  # def truthy
  #   Expr::True.new
  # end

  # # Logical NOT
  # def not(e)
  #   Expr::Not.new(e)
  # end

  # # Logical AND
  # def and(*e)
  #   Expr::And.new(e...)
  # end

  # # Logical OR
  # def or(*e)
  #   Expr::Or.new(e...)
  # end
end