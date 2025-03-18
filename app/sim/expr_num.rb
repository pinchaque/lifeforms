module ExprNum
  class Base

    # Returns shortened class name that we use for marshaling
    def short_class_name
      self.class.name.gsub(/ExprNum::/, '')
    end

    # Returns full class name from the short one
    def self.full_class_name(str)
      "ExprNum::" + str
    end
    
    # Marshals an expression into the expected built-in class format. Key "t"
    # is the type and "v" is the value. The child class should call this with
    # the value it needs to unmarshal properly.
    def marshal_value(v = nil)
      {c: short_class_name}.merge(v.nil? ? {} : {v: v})
    end

    # Unmarshals the passed-in object into an ExprBool of the correct type.
    def self.unmarshal(obj)
      class_from_name(full_class_name(obj[:c])).unmarshal_value(obj[:v])
    end
  end

  # Represents a constant numeric value
  class Const < Base
    def initialize(v)
      @value = v
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

  # Base class for arithmetic operators
  class BaseArith < Base
    
  end

  # Adds any number of values together
  class Add < BaseArith
    def initialize(*exprs)
      @exprs = exprs
    end

    def eval(ctx)
      v = 0.0
      @exprs.each { |expr| v += expr.eval(ctx) }
      v
    end
    
    def to_s
      ret = @exprs.map{ |expr| "#{expr.to_s}" }.join(" + ")
      (@exprs.count > 1) ? "(#{ret})" : ret
    end

    def marshal
      marshal_value(@exprs.map { |expr| expr.marshal })
    end

    def self.unmarshal_value(v)
      self.new(*v.map{ |i| self.unmarshal(i)})
    end
  end

  # Subtracts one value from another
  class Sub < BaseArith
    def initialize(e1, e2)
      @e1 = e1
      @e2 = e2
    end

    def eval(ctx)
      @e1.eval(ctx) - @e2.eval(ctx)
    end
    
    def to_s
      "(#{@e1.to_s} - #{@e2.to_s})"
    end

    def marshal
      marshal_value({l: @e1.marshal, r: @e2.marshal})
    end

    def self.unmarshal_value(v)
      self.new(self.unmarshal(v[:l]), self.unmarshal(v[:r]))
    end
  end

  # Multiplies values together
  class Mul < BaseArith
    def initialize(*exprs)
      @exprs = exprs
    end

    def eval(ctx)
      v = 1.0
      @exprs.each { |expr| v *= expr.eval(ctx) }
      v
    end
    
    def to_s
      ret = @exprs.map{ |expr| "#{expr.to_s}" }.join(" * ")
      (@exprs.count > 1) ? "(#{ret})" : ret
    end

    def marshal
      marshal_value(@exprs.map { |expr| expr.marshal })
    end

    def self.unmarshal_value(v)
      self.new(*v.map{ |i| self.unmarshal(i)})
    end
  end

  # Divs one value by another
  class Div < BaseArith
    def initialize(e1, e2)
      @e1 = e1
      @e2 = e2
    end

    def eval(ctx)
      @e1.eval(ctx) / @e2.eval(ctx)
    end
    
    def to_s
      "(#{@e1.to_s} / #{@e2.to_s})"
    end

    def marshal
      marshal_value({l: @e1.marshal, r: @e2.marshal})
    end

    def self.unmarshal_value(v)
      self.new(self.unmarshal(v[:l]), self.unmarshal(v[:r]))
    end
  end

  # Raises one value to the power of another
  class Pow < BaseArith
    def initialize(e1, e2)
      @e1 = e1
      @e2 = e2
    end

    def eval(ctx)
      @e1.eval(ctx) ** @e2.eval(ctx)
    end
    
    def to_s
      "(#{@e1.to_s} ^ #{@e2.to_s})"
    end

    def marshal
      marshal_value({l: @e1.marshal, r: @e2.marshal})
    end

    def self.unmarshal_value(v)
      self.new(self.unmarshal(v[:l]), self.unmarshal(v[:r]))
    end

  end
end

# The below functions are helpers to create the above classes. This is most
# useful for testing and hard-coded behaviors.

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