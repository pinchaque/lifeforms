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
    # TODO: Implement
    return x + dist, y
  end
end