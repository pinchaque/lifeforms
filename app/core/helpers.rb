# Constrains the specified number to be between 0.0 and 1.0, inclusive, so
# it can be used as a percentage.
def perc(p)
  if p > 1.0
    1.0
  elsif p < 0.0
    0.0
  else
    p
  end
end

# Converts a CamelCase string to snake_case
def camel_to_snake(s)
  s.gsub(/::/, '').
  gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
  gsub(/([a-z\d])([A-Z])/,'\1_\2').
  tr("-", "_").
  downcase
end

# Returns the class object associatd with the given name, which
# can include module "::" separators.
def class_from_name(name)
  Object.const_get(name)
end

# Returns true if val is numeric and false otherwise
def is_numeric?(val)
  begin
    Kernel.Float(val)
    return true
  rescue RangeError
    # can't convert 5.808185577559548e+114-0.015059394552572046i into Float
    return false
  rescue ArgumentError
    # Float("123.0_badstring") #=> ArgumentError: invalid value for Float(): "123.0_badstring"
    return false
  rescue TypeError
    # Float(nil) => TypeError: can't convert nil into Float
    return false
  end
end