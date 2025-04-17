module Expr
  # Base class for Expressions that take any number of operands
  class BaseMultiple < Base
    def initialize(*exprs)
      @exprs = exprs
    end

    def to_s
      ret = @exprs.map{ |expr| "#{expr.to_s}" }.join(" #{op_s} ")
      (@exprs.count > 1) ? "(#{ret})" : ret
    end

    def mutate_children(ctx, prob)
      @exprs.map! { |e| e.mutate(ctx, prob) }
    end

    # Marshal the expressions into an array
    def marshal
      marshal_value(@exprs.map { |expr| expr.marshal })
    end

    def self.unmarshal_value(v)
      self.new(*v.map{ |i| self.unmarshal(i)})
    end
  end
end