module Expr
  # Base class for Expressions that take two operands; the order of these
  # is preserved
  class BaseDuo < Base
    KEY_LEFT = :l
    KEY_RIGHT = :r

    def initialize(expr1, expr2)
      @expr1 = expr1
      @expr2 = expr2
    end
    
    def to_s
      "(#{@expr1.to_s} #{op_s} #{@expr2.to_s})"
    end

    def marshal
      marshal_value({KEY_LEFT => @expr1.marshal, KEY_RIGHT => @expr2.marshal})
    end

    def self.unmarshal_value(v)
      self.new(self.unmarshal(v[KEY_LEFT]), self.unmarshal(v[KEY_RIGHT]))
    end
  end
end