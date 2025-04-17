module Expr
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
      if obj.nil?
        nil
      else
        class_from_name(full_class_name(obj[KEY_CLASS])).unmarshal_value(obj[KEY_VALUE])
      end
    end

    def do_mutate?(prob)
      prob > Random.rand(0.0...1.0)
    end

    # Probabilistically mutates this Expr in the context of the given Lifeform.
    # prob is the probability the mutation will happen at each expr that we 
    # iterate over. Returns the new Expr to use in case we are swapping out.
    def mutate(ctx, prob)
      mutate_children(ctx, prob)
      do_mutate?(prob) ? mutate_self_real(ctx) : self
    end

    def mutate_self_real(ctx)
      # do nothing by default
      self
    end

    def mutate_children(ctx, prob)
      # do nothing - no children by default
    end
  end

  def self.unmarshal(obj)
    Expr::Base.unmarshal(obj)
  end
end