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