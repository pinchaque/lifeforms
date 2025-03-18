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
      {t: short_class_name}.merge(v.nil? ? {} : {v: v})
    end

    # Unmarshals the passed-in object into an ExprBool of the correct type.
    def self.unmarshal(obj)
      class_from_name(full_class_name(obj[:t])).unmarshal_value(obj[:v])
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
      Const.new(v[:value].to_f)
    end
  end
end

# The below functions are helpers to create the above classes. This is most
# useful for testing and hard-coded behaviors.

# Constant value
def e_const(v)
  ExprNum::Const.new(v)
end
