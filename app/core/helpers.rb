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