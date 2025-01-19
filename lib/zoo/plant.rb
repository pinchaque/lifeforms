class Plant < Lifeform

  # Rate at which energy grows in each step
  attr_accessor :growth_rate

  # Energy level at which the lifeform splits
  attr_accessor :energy_split
  
  def initialize
    super
  end

  def species
    "Plant"
  end

  def clone
    r = Plant.new
    r.growth_rate = @growth_rate
    r.energy_split = @energy_split

  end

  def run_step
    if @energy > @energy_split
      child = Plant.new
      child.energy = @energy / 2.0
      child.x, child.y = rnd_point(@x, @y, @size)
      env.

      # split this plants energy in half
      @energy /= 2.0
    else
      @energy *= (1.0 + @growth_rate)
    end
  end
end