module Skill
  class ParamDef
    # Unique identifier - convention is snake_case
    attr_accessor :id

    # User-friendly description
    attr_accessor :desc

    # Min and max allowable values
    attr_accessor :value_min, :value_max

    attr_accessor :distrib

    # Initialize the parameter definition with an id to use. This ID is used
    # to refer to this parameter throughout the project.
    def initialize(id)
      @id = id
    end

    # Generates and returns a default value for the parameter given the
    # distribution and other parameters that have been configured.
    def generate_default
      if @distrib.nil?
        constrain(0.0)
      else
        constrain(@distrib.rnd)
      end
    end

    # Constrains the specified value to be within min..max, if available.
    def constrain(v)
      if !@value_min.nil? && v < @value_min
        @value_min
      elsif !value_max.nil? && v > @value_max
        @value_max
      else
        v
      end
    end

    # Validates the specified value to ensure it is within range. Returns an
    # error message if invalid and nil if valid.
    def check_validity(v)
      if !@value_min.nil? && v < @value_min
        "#{v} is less than minimum value (#{@value_min})"
      elsif !value_max.nil? && v > @value_max
        "#{v} is greater than maximum value (#{@value_max})"
      else
        nil
      end
    end

    # Validates the specified value to ensure it is within range. Returns true
    # if valid and false otherwise.
    def valid?(v)
      check_validity(v).nil?
    end
  end
end