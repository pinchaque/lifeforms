module Expr
    # Expr wrapper around a Skill
    class Skill < Base
      # Initialise with the ID of the skill that will be executed
      def initialize(id)
        @id = id
      end
  
      def to_s
        "SKILL(#{@id})"
      end
  
      # Executes the skill with the given Context
      def eval(ctx)
        skill = ctx.lifeform.skills.fetch(@id)
        skill.nil? ? nil : skill.eval(ctx)
      end
  
      def marshal
        marshal_value(@id)
      end
  
      def self.unmarshal_value(v)
        self.new(v.to_sym)
      end
    end  
end

# Executes a Skill as an expression
def e_skill(s)
  Expr::Skill.new(s)
end