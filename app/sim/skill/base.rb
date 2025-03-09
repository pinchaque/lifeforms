module Skill
  class Base
    # Generates the id of the skill based on the class name. Override this
    # if you want to use a different ID.
    def self.id
      base_name = self.name.gsub(/^.*::/, '')
      camel_to_snake(base_name)
    end

    # Returns array of ParamDef objects for this Skill
    def self.param_defs
      [] # none by default
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
  end
end