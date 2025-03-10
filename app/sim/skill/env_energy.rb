module Skill
  class EnvEnergy < Base

    def self.param_defs
      [
        ParamDefNormalPerc(
          id: :energy_absorb_perc,
          desc: "Percentage of the environmental energy available to this lifeform that it actually absorbs",
          mean: 0.95,
          stddev: 0.05
        ),
      ]
    end

    # The amount of energy lost due to overlaps with other lifeforms. This is
    # returned as a non-negative number.
    def self.energy_overlap_loss(env, lf)
      # To calculate the loss we add up the areas of all the overlapping 
      # lifeforms of this species. Then we divide that by two because 
      # the lifeforms are splitting the energy. Then we multiply by the
      # environmental energy rate to get actual energy.
      # 
      # NOTE: This does not take into account the case where there are more than
      # 2 lifeforms overlapping and splitting the same area. The actual loss 
      # would be less if we calculated that precisely. So this is an heuristic
      # that will over-estimate the energy loss.
      env.energy_rate * 0.5 * lf.find_overlaps.map{ |oth| 
        circle_area_intersect(lf.x, lf.y, lf.radius, oth.x, oth.y, oth.radius) }.sum
    end

    def self.exec(ctx)
      env = ctx.env
      lf = ctx.lifeform

      # The gross amount of energy supplied to this lifeform based on its area
      # alone, not taking into account overlaps with other lifeforms.
      env_gross = env.energy_rate * lf.area

      # energy lost to overlaps with other lifeforms
      overlap_loss = energy_overlap_loss(env, lf)
      
      energy_net = [0.0, env_gross - overlap_loss].max

      # Calc out how much energy we can absorb from the environment
      energy_absorb = energy_net * ctx.value(:energy_absorb_perc)

      lf.energy += energy_absorb
    end
  end
end