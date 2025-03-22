module Expr
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
end

# Looks up given symbol in Context
def e_lookup(sym)
  Expr::Lookup.new(sym)
end