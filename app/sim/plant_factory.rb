class PlantFactory
  attr_accessor :env
  SPECIES_NAME = "Plant"

  def initialize(env)
    @env = env
    @species = get_species
  end

  def get_species
    s = Species.where(name: SPECIES_NAME).first
    if s.nil?
      s = Species.new(name: SPECIES_NAME).save
    end
    s
  end

  def get_skills
    [
      Skill::EnvEnergy,
      Skill::Grow
    ]
  end

  def get_program
    s_seq(
      s_skill(Skill::EnvEnergy.id)
    )
  end

  def gen
    lf = Lifeform.new
    lf.environment_id = @env.id
    lf.mark_born
    lf.energy = 10.0
    lf.size = 1.0
    lf.initial_size = 1.0
    lf.species_id = @species.id
    lf.set_random_name
    lf.set_loc_random
    lf.energy_base = 1.0
    lf.energy_exp = 3.0
    get_skills.each do |s|
      lf.register_skill(s)
    end
    lf.program = get_program
    lf
  end
end