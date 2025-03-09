module Skill
  class Base
    @@param_defs = {}

    def self.define_param(id)
      raise "param_def already exists for #{id}" if @@param_defs.key?(id)
      pd = ParamDef.new(id)
      @@param_defs[id] = pd
      yield pd if block_given?
      pd
    end

    def self.param_def(id)
      @@param_defs[id]
    end

    def self.param_defs
      @@param_defs
    end


    # attr_accessor :paramset

    # def initialize
    #   @paramset = ParamSet.new

    #   # TODO how to set initial values for parameters and define which is available for the child class
    # end

    # def prm(sym)
    #   @paramset.value(sym)
    # end
  end
end