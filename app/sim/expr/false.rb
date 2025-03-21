module Expr
  # Expresssion that always returns false; also can be used as no-op
  class False < Base
    def eval(ctx)
      false
    end

    def to_s
      "false"
    end

    def marshal
      marshal_value
    end

    def self.unmarshal_value(v)
      self.new
    end
  end  
end

# Constant FALSE
def e_false
Expr::False.new
end