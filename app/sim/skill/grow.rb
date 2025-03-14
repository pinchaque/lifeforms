module Skill
  class Grow < Base

    def self.param_defs
      [
        Skill.ParamDefNormalPerc(
          id: :energy_reserve_perc,
          desc: "Target percentage of the incoming energy that this lifeform tries to move into its energy stores. It will grow or shrink to try to achieve this percentage",
          mean: 0.1,
          stddev: 0.02
        ),
      ]
    end

    def self.exec(ctx)
      #ctx.lifeform.energy += energy_absorb(ctx)
      #      # we are self-sustaining but might be not sized right (too big or too 
      # small). so let's figure out what that size should be and get halfway 
      # there
      # size_target = energy_fn.size(e_meta_target)
      # size_new = (self.size + size_target) / 2.0
      # Log.trace(sprintf("SUSTAINING: energy:%f size_old:%f size_target:%f size_new:%f", 
      #   self.energy, self.size, size_target, size_new))
      # self.size = size_new

    end
  end
end