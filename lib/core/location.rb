class Location
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  # Returns a new Location object at a random place in an environment
  # that is width x height big.
  def self.random(width, height)
    r = Random.new
    Location.new(r.rand(0.0..width.to_f), r.rand(0.0..height.to_f))
  end

  # Returns a new Location object that is dist away from another location
  # and in an environment that is widthxheight big.
  def self.at_dist(width, height, other, dist)
    # random angle in radians
    ang = Random.rand(0.0..2.0*Math::PI)

    # convert polar to cartesian
    dx = dist * Math.cos(ang)
    dy = dist * Math.sin(ang)

    # limit to canvas bounds
    x = other.x + dx
    x = 0.0 if x < 0.0
    x = width if x > width
    
    y = other.y + dy
    y = 0.0 if y < 0.0
    y = height if y > height

    Location.new(x, y)
  end
end