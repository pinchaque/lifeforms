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
    p.species_id = @species.id
    p.set_random_name
    p.set_loc_random
    p.energy_absorb_perc = 0.5
    p.energy_metabolic_rate = 1.2
    p.energy_size_ratio = 2.0
    p.growth_invest_perc = 0.4
    p.repro_threshold = 20.0
    p.repro_num_offspring = 3
    p.repro_energy_inherit_perc = 0.8
    p
  end
end