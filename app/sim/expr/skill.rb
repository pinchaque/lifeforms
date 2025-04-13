module Expr
  # Expr wrapper around a Skill
  class Skill < Base
    attr_accessor :id

    # Initialize with the ID of the skill that will be executed
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

    # Mutates by selecting a different available skill ID. If there are no
    # others then no change is made.
    def mutate_real(ctx)
      ids = ctx.lifeform.skills.skills.keys
      ids.delete(@id)
      @id = ids.sample if ids.count > 0
    end
  end
end

# Executes a Skill as an expression
def e_skill(s)
  Expr::Skill.new(s)
end