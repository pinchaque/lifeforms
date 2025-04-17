module Expr
  # Base class for numeric comparisons; the component expressions should return
  # numbers when evaluated
  class BaseNumCmp < BaseDuo
    def get_val(ctx, expr_num)
      val = expr_num.eval(ctx)

      begin
        Kernel.Float(val)
      rescue ArgumentError
        # Float("123.0_badstring") #=> ArgumentError: invalid value for Float(): "123.0_badstring"
        raise "Value for expression '#{expr_num.to_s}' is not numeric ('#{val}')"
      rescue TypeError
        # Float(nil) => TypeError: can't convert nil into Float
        raise "Value for expression '#{expr_num.to_s}' is nil"
      end
    end

    # Mutates the comparison by switching to a random operator.
    def mutate_self_real(ctx)
      [Equal, GT, GTE, LT, LTE].sample.new(@expr1, @expr2)
    end

    def eval(ctx)
      cmp(get_val(ctx, @expr1), get_val(ctx, @expr2))
    end
  end
end