module Zoo
  class Grazer < Base

    def get_skills
      [
        Skill::MoveToFood,
        Skill::Eat,
        Skill::Grow,
        Skill::Reproduce
      ]
    end

    def get_program
      e_seq(
        e_skill(Skill::MoveToFood.id),
        e_skill(Skill::Eat.id)
      )
    end

    def set_attrs(lf)
      lf.energy = 100.0
      lf.size = 1.0
      lf.initial_size = 1.0
      lf.energy_base = 1.0
      lf.energy_exp = 3.0      
    end
  end
end