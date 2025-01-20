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
    ang = Random.rand(0.0..2.0*PI) # random angle in radians
    dx = dist * cos(ang) # convert polar to cartesian
    dy = dist * sin(ang)
    Location.new(other.x + dx, other.y + dy)
  end
end