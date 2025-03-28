# Represents a two-dimensional coordinate and provides methods for
# arithemetic and conversion between cartesian and polar.
class Coord

  attr_reader :x, :y, :r, :ang
  
  def initialize
    @x = 0.0
    @y = 0.0
    @r = 0.0
    @ang = 0.0
  end

  # Construct a new object from cartesian coordinates
  def self.xy(x, y)
    self.new.set_xy(x, y)
  end

  # Construct a new object from polar coordinates
  def self.polar(r, ang)
    self.new.set_polar(r, ang)
  end

  # Sets the cartesian coordinates for the object (and recomputes polar)
  def set_xy(x, y)
    @x = x
    @y = y
    compute_polar
    self
  end

  # Sets the polar coordinates for the object (and recomputes cartesian)
  def set_polar(r, ang)
    @r = r
    @ang = ang
    compute_cartesian
    self 
  end

  def to_s
    "(#{@x}, #{@y})"
  end

  # Adds another Coord to this one and returns a new Coord
  def +(o)
    Coord.xy(@x + o.x, @y + o.y)
  end

  # Subtracts another Coord from this one and returns a new Coord
  def -(o)
    Coord.xy(@x - o.x, @y - o.y)
  end

  # Returns true if self is equal to o, false otherwise. 
  def ==(o)
    (@x == o.x) && (@y == o.y)
  end

  # Returns true if self is inequal to o, false otherwise. 
  def !=(o)
    !(self == o)
  end

  private
  # Computes polar coordinate data members from cartesian
  def compute_polar
    @r = Math.sqrt(@x ** 2 + @y ** 2)
    @ang = Math.atan2(@y, @x)
  end

  # Computes cartesian coordinate data members from polar
  def compute_cartesian
    @x = @r * Math.cos(@ang)
    @y = @r * Math.sin(@ang)
  end
end