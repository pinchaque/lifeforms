module Skill
  class Param
    # Unique identifier - convention is snake_case
    attr_accessor :id

    # User-friendly description
    attr_accessor :desc

    # Default value
    attr_accessor :value_default

    # Min and max value
    attr_accessor :value_min, :value_max

    # Current value
    attr_accessor :value

    # TODO need mutate, distribution
    # TODO need way to get value, validate it
  end
end