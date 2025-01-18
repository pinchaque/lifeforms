class Lifeform

  # Environment to which this lifeform belongs
  attr_accessor :env
  
  # Individual name for this lifeform
  attr_accessor :name

  # Location for this lifeform wihtin the environment
  attr_accessor :x, :y
  
  def initialize
    @name = gen_name
  end

  def run_step
    # nothing to do in base class
  end

  # Species name of this lifeform
  def species
    abort "Species name undefined"
  end

  def gen_name
    sprintf("Name%04d", Random.rand(0...10000))
  end

  def loc_str
    fmt = "%.2f"
    sprintf(fmt, @x) + ", " + sprintf(fmt, @y)
  end

  def to_s
    "#{@species} #{@name} [#{loc_str}]"
  end
end