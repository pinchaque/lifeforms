class PlantFactory
  attr_accessor :energy_min, :energy_max
  attr_accessor :growth_rate, :energy_split
  attr_accessor :size
  attr_accessor :env
  SPECIES_NAME = "Plant"

  def initialize(env)
    @env = env
    @energy_min = 10.0
    @energy_max = 20.0
    @energy_split = 30.0
    @growth_rate = 0.2
    @size = 1.0
    @species = get_species
  end

  def get_species
    s = Species.where(name: SPECIES_NAME).first
    if s.nil?
      s = Species.new(name: SPECIES_NAME).save
    end
    s
  end

  def gen
    p = Plant.new
    p.environment_id = @env.id
    p.energy = Random.rand(@energy_min..@energy_max)
    p.size = @size
    p.growth_rate = @growth_rate
    p.energy_split = @energy_split
    p.species_id = @species.id
    p.set_random_name
    p.set_loc_random
    p
  end
end