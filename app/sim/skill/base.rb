module Skill
  # Base class to use for all skills. It provides behavior that is needed for
  # the Skills to work within the simulation.
  class Base
    # Generates the id of the skill based on the class name. Override this
    # if you want to use a different ID.
    def self.id
      base_name = self.name.gsub(/^.*::/, '')
      camel_to_snake(base_name).to_sym
    end

    # Returns array of ParamDef objects for this Skill
    def self.param_defs
      [] # none by default
    end

    # Returns hash of the observations a Skill provides. Key is the symbol ID
    # to refer to it and value is the name of the function to call. The function
    # will be called with a Context as the argument.
    def self.observations
      {} # none by default
    end

    # Generates the Param objects for this skill. If a block is given then they
    # will be yielded, otherwise returned as an array.
    def self.generate_params
      r = []
      param_defs.each do |pd|
        p = Param.new(pd)
        if block_given? 
          yield p
        else
          r << p
        end
      end
      block_given? ? nil : r
    end

    # Base class eval, shouldn't be called
    def self.eval(ctx)
      raise "Tried to execute Skill::Base"
    end

    # Unmarshals the value and returns a new Skill class of the correct type
    def self.unmarshal(obj)
      class_from_name(obj)
    end

    # Marshals this Skill to a value.
    def self.marshal
      name
    end
  end
end