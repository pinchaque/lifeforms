class PlantFactory
  attr_accessor :energy_min, :energy_max
  attr_accessor :size
  attr_accessor :env
  SPECIES_NAME = "Plant"

  def initialize(env)
    @env = env
    @energy_min = 10.0
    @energy_max = 20.0
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
    p.species_id = @species.id
    p.set_random_name
    p.set_loc_random
    p.energy_absorb_perc = 0.9
    p.energy_base = 5.0
    p.energy_reserve_perc = 0.7
    p.repro_threshold = 50.0
    p.repro_num_offspring = 3
    p.repro_energy_inherit_perc = 0.95
    p
  end
end