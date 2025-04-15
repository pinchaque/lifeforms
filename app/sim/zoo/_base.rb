module Zoo
  class Base
    attr_accessor :env, :species

    def initialize(env, species)
      @env = env
      @species = species
    end

    def get_skills
      [] # none by default
    end

    def get_program
      e_true # no-op by default
    end

    def set_attrs(lf)
      # do nothing
    end

    # Generates but DOES NOT SAVE a new lifeform. Uses methods from derived
    # classes to set up skills, program, and parameters.
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
      set_attrs(lf)
      lf
    end
  end
end