class Constraint
  
  # Unmarshals from an object and returns a new Constraint object of the correct type
  def self.unmarshal(obj)
    class_from_name(obj[:class]).unmarshal(obj)
  end
end

# Constrains a number within a min..max range, either of which is optional.
class ConstraintMinMax < Constraint
  attr_accessor :min, :max

  def initialize(min, max)
    @min = min
    @max = max
  end
  
  # Constrains the specified value to be within min..max, if available.
  def constrain(v)
    if !@min.nil? && v < @min
      @min
    elsif !max.nil? && v > @max
      @max
    else
      v
    end
  end

  # Validates the specified value to ensure it is within range. Returns an
  # error message if invalid and nil if valid.
  def check_validity(v)
    if !@min.nil? && v < @min
      "#{v} is less than minimum value (#{@min})"
    elsif !max.nil? && v > @max
      "#{v} is greater than maximum value (#{@max})"
    else
      nil
    end
  end

  # Validates the specified value to ensure it is within range. Returns true
  # if valid and false otherwise.
  def valid?(v)
    check_validity(v).nil?
  end

  # Marshals this object built-in Ruby classes
  def marshal
    {
      class: self.class.to_s,
      min: @min,
      max: @max
    }
  end

  def self.unmarshal(obj)
    ConstraintMinMax.new(obj[:min], obj[:max])
  end
end

# Constrains a number to be an integer
class ConstraintInt < Constraint
  def constrain(v)
    v.round
  end

  # Validates the specified value to ensure it is an integer. Returns an
  # error message if it is not and nil if valid.
  def check_validity(v)
    if valid?(v)
      nil
    else
      "#{v} is not an integer"
    end
  end

  # Validates the specified value to ensure it is an integer. Returns true
  # if valid and false otherwise.
  def valid?(v)
    v.integer?
  end

  # Marshals this object built-in Ruby classes
  def marshal
    {
      class: self.class.to_s
    }
  end

  def self.unmarshal(obj)
    ConstraintInt.new
  end
end