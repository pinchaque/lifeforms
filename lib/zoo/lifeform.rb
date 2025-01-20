require 'random/formatter'

class Lifeform  
  # Individual name for this lifeform
  attr_accessor :name

  # Energy level of this lifeform
  attr_accessor :energy

  # Size of this lifeform
  attr_accessor :size
  
  def initialize
    @name = gen_name
    @energy = 0.0
    @size = 1.0
    @uuid = Random.uuid
  end

  def id
    @uuid.to_s
  end

  # 
  def reproduce(num = 1)
    # energy is divided evenly among parent and children
    e_new = energy / (num + 1)
    @energy = e_new # update parent energy

    children = []
    for i in 0...num do
      child = create
      child.copy_from(self)
      child.energy = e_new
      child.name = gen_name
      yield child if block_given? 
      children << child
    end
    children
  end

  def create
    abort "Called create() on base class"
  end

  # Copies the attributes of another lifeform of the same species into this one
  def copy_from(other)
    abort "Species does not match (#{species} != #{other.species})" if species != other.species
  end

  def run_step(env)
    # nothing to do in base class
  end

  # Species name of this lifeform
  def species
    abort "Species name undefined"
  end

  def gen_name
    (NameParts::DESCRIPTORS.sample.capitalize + " " + NameParts::GIVENS.sample.capitalize).strip
  end

  def energy_str
    sprintf("%.2f", @energy)
  end

  def to_s
    "#{species} #{@name} [Energy: #{energy_str}]"
  end
end