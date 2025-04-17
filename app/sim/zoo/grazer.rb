module Zoo
  class Grazer < Base

    def get_skills
      [
        Skill::MoveToFood,
        Skill::Eat,
        Skill::Reproduce
      ]
    end

    def get_program
      e_if( # REPRODUCTION
        # IF: We have good energy reserves
        e_gt(e_lookup(:lf_energy), e_mul(e_const(100.0), e_lookup(:lf_metabolic_energy))), 

        # THEN: Reproduce
        e_skill(Skill::Reproduce.id),

        # ELSE: Try to get food
        e_if(
          # IF: We weren't able to eat our metabolic energy in food
          e_lt(e_skill(Skill::Eat.id), e_lookup(:lf_metabolic_energy)),

          # THEN: Move to the best food we can find
          e_skill(Skill::MoveToFood.id)
        )
      )
    end

    def set_attrs(lf)
      lf.energy = 100.0
      lf.size = 1.0
      lf.initial_size = 1.0
      lf.energy_base = 10.0
      lf.energy_exp = 3.0      
    end
  end
end