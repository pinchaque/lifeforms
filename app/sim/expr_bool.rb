module ExprBool
  class Base

    # Returns shortened class name that we use for marshaling
    def short_class_name
      self.class.name.gsub(/ExprBool::/, '')
    end

    # Returns full class name from the short one
    def self.full_class_name(str)
      "ExprBool::" + str
    end
    
    # Marshals an expression into the expected built-in class format. Key "t"
    # is the type and "v" is the value. The child class should call this with
    # the value it needs to unmarshal properly.
    def marshal_value(v = nil)
      {t: short_class_name}.merge(v.nil? ? {} : {v: v})
    end

    # Unmarshals the passed-in object into an ExprBool of the correct type.
    def self.unmarshal(obj)
      class_from_name(full_class_name(obj[:t])).unmarshal_value(obj[:v])
    end
  end

  # Expresssion that always returns true
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
      True.new
    end
  end

  # Logical NOT
  class Not < Base
    def initialize(expr)
      @expr = expr
    end

    def eval(ctx)
      !@expr.eval(ctx)
    end
    
    def to_s
      "!#{@expr.to_s}"
    end

    def marshal
      marshal_value(@expr.marshal)
    end

    def self.unmarshal_value(v)
      Not.new(self.unmarshal(v))
    end
  end

  # Logical AND
  class And < Base
    def initialize(*exprs)
      @exprs = exprs
    end

    def eval(ctx)
      @exprs.all? { |expr| expr.eval(ctx) }
    end
    
    def to_s
      ret = @exprs.map { |expr| "#{expr.to_s}" }.join(" && ")
      (@exprs.count > 1) ? "(#{ret})" : ret
    end

    def marshal
      marshal_value(@exprs.map { |expr| expr.marshal })
    end

    def self.unmarshal_value(v)
      And.new(*v.map{ |i| self.unmarshal(i)})
    end
  end

  # Logical OR
  class Or < Base
    def initialize(*exprs)
      @exprs = exprs
    end

    def eval(ctx)
      @exprs.any? { |expr| expr.eval(ctx) }
    end
    
    def to_s
      ret = @exprs.map{ |expr| "#{expr.to_s}" }.join(" || ")
      (@exprs.count > 1) ? "(#{ret})" : ret
    end

    def marshal
      marshal_value(@exprs.map { |expr| expr.marshal })
    end

    def self.unmarshal_value(v)
      Or.new(*v.map{ |i| self.unmarshal(i)})
    end
  end

  # Base class for numeric comparisons
  class NumCmp < Base
    def initialize(e1, e2, op_s)
      @e1 = e1
      @e2 = e2
      @op_s = op_s
    end
    
    def to_s
      "(#{@e1} #{@op_s} #{@e2})"
    end

    def get_val(ctx, str)
      sym = str.to_sym
      raise "Missing value for symbol '#{sym}'" unless ctx.has_key?(sym)
      val = ctx.fetch(sym)
      begin
        Kernel.Float(val)
      rescue ArgumentError
        # Float("123.0_badstring") #=> ArgumentError: invalid value for Float(): "123.0_badstring"
        raise "Value for '#{sym}' is not numeric ('#{val}')"
      rescue TypeError
        # Float(nil) => TypeError: can't convert nil into Float
        raise "Value for '#{sym}' is nil"
      end
    end

    def eval(ctx)
      cmp(get_val(ctx, @e1), get_val(ctx, @e2))
    end

    def marshal
      marshal_value({l: @e1, r: @e2})
    end

    def self.unmarshal_value(v)
      self.new(v[:l], v[:r])
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
  ExprBool::True.new
end

# Logical NOT
def e_not(e)
  ExprBool::Not.new(e)
end

# Logical AND
def e_and(*e)
  ExprBool::And.new(*e)
end

# Logical OR
def e_or(*e)
  ExprBool::Or.new(*e)
end

# Numeric equality
def e_equal(e1, e2)
  ExprBool::Equal.new(e1, e2)
end

# Numeric less than
def e_lt(e1, e2)
  ExprBool::LT.new(e1, e2)
end

# Numeric less than or equal to
def e_lte(e1, e2)
  ExprBool::LTE.new(e1, e2)
end

# Numeric greater than
def e_gt(e1, e2)
  ExprBool::GT.new(e1, e2)
end

# Numeric greater than or equal to
def e_gte(e1, e2)
  ExprBool::GTE.new(e1, e2)
end