# Represents a two-dimensional coordinate and provides methods for
# arithemetic and conversion between cartesian and polar.
class Coord

  attr_accessor :x, :y
  
  def initialize
    @x = 0.0
    @y = 0.0
  end

  def self.xy(x, y)
    c = self.new
    c.x = x
    c.y = y
    c
  end

  def r
    Math.sqrt(@x ** 2 + @y ** 2)
  end

  def ang
    Math.atan2(@y, @x)
  end
end



# Returns distance between two points
def xy_dist(x0, y0, x1, y1)
  Math.sqrt((x1 - x0) ** 2 + (y1 - y0) ** 2)
end
