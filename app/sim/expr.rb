module Expr
  #####################################################################
  # BASE CLASSES
  #####################################################################

  # Base class for all expressions, which can return bool or float
  class Base
    KEY_CLASS = :c
    KEY_VALUE = :v

    # Returns shortened class name that we use for marshaling
    def short_class_name
      self.class.name.gsub(/Expr::/, '')
    end

    # Returns full class name from the short one
    def self.full_class_name(str)
      "Expr::" + str
    end
    
    # Marshals an expression into the expected built-in class format. Key "c"
    # is the class and "v" is the value. The child class should call this with
    # the value it needs to unmarshal properly.
    def marshal_value(v = nil)
      {KEY_CLASS => short_class_name}.merge(v.nil? ? {} : {KEY_VALUE => v})
    end

    # Unmarshals the passed-in object into an Expr of the correct type.
    def self.unmarshal(obj)
      class_from_name(full_class_name(obj[KEY_CLASS])).unmarshal_value(obj[KEY_VALUE])
    end
  end

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

  # Base class for Expressions that take any number of operands
  class BaseMultiple < Base
    def initialize(*exprs)
      @exprs = exprs
    end

    def to_s
      ret = @exprs.map{ |expr| "#{expr.to_s}" }.join(" #{op_s} ")
      (@exprs.count > 1) ? "(#{ret})" : ret
    end

    # Marshal the expressions into an array
    def marshal
      marshal_value(@exprs.map { |expr| expr.marshal })
    end

    def self.unmarshal_value(v)
      self.new(*v.map{ |i| self.unmarshal(i)})
    end
  end

  #####################################################################
  # BOOLEAN EXPRESSIONS
  #####################################################################

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
      self.new
    end
  end

  # Logical NOT
  class Not < BaseSingle
    def eval(ctx)
      !@expr.eval(ctx)
    end
    
    def to_s
      "!#{@expr.to_s}"
    end
  end

  # Logical AND
  class And < BaseMultiple
    def eval(ctx)
      @exprs.all? { |expr| expr.eval(ctx) }
    end

    def op_s
      "&&"
    end
  end

  # Logical OR
  class Or < BaseMultiple
    def eval(ctx)
      @exprs.any? { |expr| expr.eval(ctx) }
    end

    def op_s
      "||"
    end
  end

  # Base class for numeric comparisons; the component numeric expressions
  # should be of type ExprNum.
  class NumCmp < BaseDuo
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

    def eval(ctx)
      cmp(get_val(ctx, @expr1), get_val(ctx, @expr2))
    end
  end

  # Equality
  class Equal < NumCmp
    def op_s
      "=="
    end

    def cmp(a, b)
      a == b
    end
  end

  # Less Than
  class LT < NumCmp
    def op_s
      "<"
    end

    def cmp(a, b)
      a < b
    end
  end

  # Less Than or Equal
  class LTE < NumCmp
    def op_s
      "<="
    end

    def cmp(a, b)
      a <= b
    end
  end

  # Greater Than
  class GT < NumCmp
    def op_s
      ">"
    end

    def cmp(a, b)
      a > b
    end
  end

  # Greater Than or Equal
  class GTE < NumCmp
    def op_s
      ">="
    end

    def cmp(a, b)
      a >= b
    end
  end

  #####################################################################
  # NUMERIC EXPRESSIONS
  #####################################################################
  # Represents a constant numeric value
  class Const < Base
    def initialize(v)
      @value = v.to_f
    end

    def eval(ctx)
      @value
    end

    def to_s
      @value.to_s
    end

    def marshal
      marshal_value(@value)
    end

    def self.unmarshal_value(v)
      self.new(v.to_f)
    end
  end

  # Represents a value that is looked up from the Context
  class Lookup < Base
    def initialize(id)
      @id = id.to_sym
    end

    def eval(ctx)
      raise "Missing value for id '#{@id}'" unless ctx.has_key?(@id)
      ctx.fetch(@id)
    end

    def to_s
      @id.to_s
    end

    def marshal
      marshal_value(@id.to_s)
    end

    def self.unmarshal_value(v)
      self.new(v.to_sym)
    end
  end

  # Adds any number of values together
  class Add < BaseMultiple
    def eval(ctx)
      v = 0.0
      @exprs.each { |expr| v += expr.eval(ctx) }
      v
    end

    def op_s
      "+"
    end
  end

  # Subtracts one value from another
  class Sub < BaseDuo
    def eval(ctx)
      @expr1.eval(ctx) - @expr2.eval(ctx)
    end

    def op_s
      "-"
    end
  end

  # Multiplies values together
  class Mul < BaseMultiple
    def eval(ctx)
      v = 1.0
      @exprs.each { |expr| v *= expr.eval(ctx) }
      v
    end
    
    def op_s
      "+"
    end
  end

  # Divs one value by another
  class Div < BaseDuo
    def eval(ctx)
      @expr1.eval(ctx) / @expr2.eval(ctx)
    end

    def op_s
      "/"
    end
  end

  # Raises one value to the power of another
  class Pow < BaseDuo
    def eval(ctx)
      @expr1.eval(ctx) ** @expr2.eval(ctx)
    end

    def op_s
      "^"
    end
  end
end

#####################################################################
# HELPER FUNCTIONS
#####################################################################

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

# Constant value
def e_const(v)
  ExprNum::Const.new(v)
end

# Looks up given symbol in Context
def e_lookup(sym)
  ExprNum::Lookup.new(sym)
end

# Adds expressions together
def e_add(*e)
  ExprNum::Add.new(*e)
end

# Subtracts one expression from another
def e_sub(e1, e2)
  ExprNum::Sub.new(e1, e2)
end

# Multiplies expressions together
def e_mul(*e)
  ExprNum::Mul.new(*e)
end

# Divs one expression by another
def e_div(e1, e2)
  ExprNum::Div.new(e1, e2)
end

# Raises one expression to the power of another
def e_pow(e_base, e_exp)
  ExprNum::Pow.new(e_base, e_exp)
end