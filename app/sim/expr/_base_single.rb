module Expr
  # Base class for Expressions that have just one operand
  class BaseSingle < Base
    def initialize(expr)
      @expr = expr
    end

    # Marshal the value as is
    def marshal
      marshal_value(@expr.marshal)
    end

    def self.unmarshal_value(v)
      self.new(self.unmarshal(v))
    end
  end
end