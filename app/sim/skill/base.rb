module Skill
  class Base
    attr_accessor :paramset

    def initialize
      @paramset = ParamSet.new

      # TODO how to set initial values for parameters and define which is available for the child class
    end

    def prm(sym)
      @paramset.value(sym)
    end
  end
end