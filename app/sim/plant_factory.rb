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
      Skill::Grow,
      Skill::Reproduce
    ]
  end

  def get_program
    e_seq(
      e_skill(Skill::EnvEnergy.id), # Absorb environmental energy
      e_if(
        # IF: Environmental energy is more than 2x metabolic
        e_gt(e_lookup(:env_energy), e_mul(e_const(2.0), e_lookup(:lf_metabolic_energy))), 
        # THEN: Grow larger
        e_skill(Skill::Grow.id), 
        # ELSE: Do nothing
        e_true))
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