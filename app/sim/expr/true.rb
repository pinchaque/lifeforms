module Expr
    # Expresssion that always returns true; also can be used as no-op
    class True < Base
      def eval(ctx)
        true
      end
  
      def to_s
        "true"
      end
  
      def marshal
        marshal_value
      end
  
      def self.unmarshal_value(v)
        self.new
      end
    end  
end

# Constant TRUE
def e_true
  Expr::True.new
end