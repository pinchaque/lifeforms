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

  def create
    Plant.new
  end

  def copy_from(other)
    super
    @growth_rate = other.growth_rate
    @energy_split = other.energy_split
  end

  def run_step(env)
    super(env)
    if @energy > @energy_split
      logf("%s is reproducing (%.2f > %.2f)", to_s, @energy, @energy_split)
      reproduce.each do |child|
        env.add_lifeform_dist(child, size)
        logf("Added child %s", child.to_s)
      end
    else
      @energy *= (1.0 + @growth_rate)
    end
  end
end