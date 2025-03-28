module Zoo
  class Plant < Base

    def get_skills
      [
        Skill::EnvEnergy,
        Skill::Grow,
        Skill::Shrink,
        Skill::Reproduce
      ]
    end

    def get_program
      e_seq(
        e_skill(Skill::EnvEnergy.id), # Absorb environmental energy

        e_if(
          # IF we're net-positive on energy coming in...
          e_gt(e_lookup(:env_energy), e_lookup(:lf_metabolic_energy)),
          
          # THEN we are in a sustainable situation so we can grow and reproducce
          e_seq(
            e_if( # GROWTH
              # IF: we have an environmental energy surplus
              e_gt(e_lookup(:env_energy), e_mul(e_const(2.0), e_lookup(:lf_metabolic_energy))), 
              # THEN: Grow larger
              e_skill(Skill::Grow.id)),
            
            e_if( # REPRODUCTION
              # IF: We have good energy reserves
              e_gt(e_lookup(:lf_energy), e_mul(e_const(20.0), e_lookup(:lf_metabolic_energy))), 
              # THEN: Reproduce
              e_skill(Skill::Reproduce.id))
            ),

            # ELSE we are not sustainable and need to shrink
            e_skill(Skill::Shrink.id)
          )
        )
    end

    def set_attrs(lf)
      lf.energy = 10.0
      lf.size = 1.0
      lf.initial_size = 1.0
      lf.energy_base = 1.0
      lf.energy_exp = 3.0      
    end
  end
end