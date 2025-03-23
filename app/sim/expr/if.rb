module Expr
    # Represents a conditional: one expression will execute if true, the other
  # if false
  class If < Base
    # Conditional expression, expression to execute if true, expression to 
    # execute if false.
    def initialize(expr_bool, expr_true, expr_false = nil)
      @expr_bool = expr_bool
      @expr_true = expr_true
      @expr_false = expr_false
    end

    def to_s
      "(IF #{@expr_bool.to_s} THEN #{@expr_true.to_s}" + 
      (@expr_false.nil? ? "" : " ELSE #{@expr_false.to_s}") +
      ")"
    end

    # Evaluates the expression and executes the true or false expression
    # accordingly, returning the result of the expression executed.
    def eval(ctx)
      if @expr_bool.eval(ctx)
        @expr_true.eval(ctx)
      elsif @expr_false.nil?
        nil
      else
        @expr_false.eval(ctx)
      end
    end

    def marshal
      h = {
        if: @expr_bool.marshal,
        then: @expr_true.marshal
      }      
      h[:else] = @expr_false.marshal unless @expr_false.nil?
      marshal_value(h)
    end

    def self.unmarshal_value(v)
      self.new(
        Expr::Base.unmarshal(v[:if]), 
        self.unmarshal(v[:then]), 
        self.unmarshal(v[:else]))
    end
  end
end

# Executes e_true or e_false depending on expr_bool
def e_if(expr_bool, e_true, e_false = nil)
  Expr::If.new(expr_bool, e_true, e_false)
end