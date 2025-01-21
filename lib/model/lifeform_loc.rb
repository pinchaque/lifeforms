class LifeformLoc < Sequel::Model
  # Returns a new Location object at a random place in an environment
  # that is width x height big.
  def self.random(width, height)
    r = Random.new
    LifeformLoc.new(x: r.rand(0.0..width.to_f), y: r.rand(0.0..height.to_f))
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
    xnew = other.x + dx
    xnew = 0.0 if xnew < 0.0
    xnew = width if xnew > width
    
    ynew = other.y + dy
    ynew = 0.0 if ynew < 0.0
    ynew = height if ynew > height

    LifeformLoc.new(x: xnew, y: ynew)
  end

  def to_s
    "(" + [x, y].map{ |a| sprintf("%.2f", a)}.join(", ") + ")"
  end
end