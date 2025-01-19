class Lifeform

  # Environment to which this lifeform belongs
  attr_accessor :env
  
  # Individual name for this lifeform
  attr_accessor :name

  # Location for this lifeform wihtin the environment
  attr_accessor :x, :y

  # Energy level of this lifeform
  attr_accessor :energy
  
  def initialize
    @name = gen_name
    @energy = 0.0
  end

  def run_step
    # nothing to do in base class
  end

  # Species name of this lifeform
  def species
    abort "Species name undefined"
  end

  def gen_name
    NameParts::DESCRIPTORS.sample.capitalize + " " + NameParts::GIVENS.sample.capitalize
  end

  def loc_str
    fmt = "%.2f"
    sprintf(fmt, @x) + ", " + sprintf(fmt, @y)
  end

  def energy_str
    sprintf("%.2f", @energy)
  end

  def to_s
    "#{@species} #{@name} [Energy: #{energy_str}] [Loc: #{loc_str}]"
  end
end