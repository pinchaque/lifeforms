module Statement
  class Base

    # Returns shortened class name that we use for marshaling
    def short_class_name
      self.class.name.gsub(/Statement::/, '')
    end

    # Returns full class name from the short one
    def self.full_class_name(str)
      "Statement::" + str
    end
    
    # Marshals an expression into the expected built-in class format. Key "t"
    # is the type and "v" is the value. The child class should call this with
    # the value it needs to unmarshal properly.
    def marshal_value(v = nil)
      {c: short_class_name}.merge(v.nil? ? {} : {v: v})
    end

    # Unmarshals the passed-in object into a Statement of the correct type.
    def self.unmarshal(obj)
      class_from_name(full_class_name(obj[:c])).unmarshal_value(obj[:v])
    end      
  end

  class Noop < Base
    def initialize
    end

    def to_s
      "NOOP()"
    end

    def exec(ctx)
      # do nothing
    end

    def marshal
      marshal_value
    end

    def self.unmarshal_value(v)
      Noop.new
    end
  end

  # Represents a sequence of statements that are executed in order
  class Sequence < Base
    # List of any number of statements to execute.
    def initialize(*sts)
      @sts = sts
    end

    def to_s
      sep = "\n  - "
      "SEQ(" + sep + 
      @sts.map{ |st| st.to_s }.join(sep) +
      "\n)"
    end

    # Executes sequence of statements in order, returning array of their
    # results.
    def exec(ctx)
      @sts.map { |st| st.exec(ctx) }
    end

    def marshal
      marshal_value(@sts.map { |st| st.marshal })
    end

    def self.unmarshal_value(v)
      Sequence.new(*v.map{ |i| self.unmarshal(i)})
    end
  end

  # Represents a conditional: one statement will execute if true, the other
  # if false
  class If < Base
    # Conditional expression, statement to execute if true, statement to 
    # execute if false.
    def initialize(expr_bool, s_true, s_false)
      @expr_bool = expr_bool
      @s_true = s_true
      @s_false = s_false
    end

    def to_s
      "IF(#{@expr_bool.to_s}\n" +
      "  THEN #{@s_true.to_s}\n" +
      "  ELSE #{@s_false.to_s}\n)"
    end

    # Evaluates the expression and executes the true or false statement
    # accordingly, returning the result of the statement executed.
    def exec(ctx)
      if @expr_bool.eval(ctx)
        @s_true.exec(ctx)
      else
        @s_false.exec(ctx)
      end
    end

    def marshal
      marshal_value(
        if: @expr_bool.marshal,
        then: @s_true.marshal,
        else: @s_false.marshal
      )
    end

    def self.unmarshal_value(v)
      If.new(
        Expr::Base.unmarshal(v[:if]), 
        self.unmarshal(v[:then]), 
        self.unmarshal(v[:else]))
    end
  end

  # Statement wrapper around a Skill
  class Skill < Base
    # Initialie with the ID of the skill that will be executed
    def initialize(id)
      @id = id
    end

    def to_s
      "SKILL(#{@id})"
    end

    # Executes the skill with the given Context
    def exec(ctx)
      skill = ctx.lifeform.skills.fetch(@id)
      skill.exec(ctx) unless skill.nil?
    end

    def marshal
      marshal_value(@id)
    end

    def self.unmarshal_value(v)
      Skill.new(v.to_sym)
    end
  end


  # Unmarshals the specified object into the correct Statement child class
  def self.unmarshal(obj)
    Base::unmarshal(obj)
  end
end

# The below functions are helpers to create the above classes. This is most
# useful for testing and hard-coded behaviors.


# No-op
def s_noop
  Statement::Noop.new
end

# Sequence of statements
def s_seq(*sts)
  Statement::Sequence.new(*sts)
end

# Executes s_true or s_false depending on expr_bool
def s_if(expr_bool, s_true, s_false)
  Statement::If.new(expr_bool, s_true, s_false)
end

# Executes a Skill as a statement
def s_skill(s)
  Statement::Skill.new(s)
end