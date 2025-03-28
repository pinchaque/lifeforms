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
        e_seq(
          e_skill(Skill::MoveToFood.id),
          e_skill(Skill::Eat.id),
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