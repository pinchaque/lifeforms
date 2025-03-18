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
    def self.overlap_loss(ctx)
      lf = ctx.lifeform
      env = ctx.env
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

    # The gross amount of energy supplied to this lifeform based on its area
    # alone, not taking into account overlaps with other lifeforms.
    def self.env_gross(ctx)
      ctx.env.energy_rate * ctx.lifeform.area
    end

    # Net energy available to us after subtracting off overlap loss; >= 0
    def self.energy_net(ctx)
      [0.0, env_gross(ctx) - overlap_loss(ctx)].max
    end

    # Calc out how much energy we can absorb from the environment
    def self.energy_absorb(ctx)
      energy_net(ctx) * ctx.value(:energy_absorb_perc)
    end

    # Adds our absorbable energy to the lifeform's energy stores. This is
    # the total provided by the environment, minus that excluded by overlaps,
    # times the absorbtion percentage.
    def self.exec(ctx)
      lf = ctx.lifeform
      old_energy = lf.energy
      egy_absorb = energy_absorb(ctx)
      lf.energy += egy_absorb
      lf.save
      Log.trace(sprintf("[EnvEnergy] Energy changed from %.2f to %.2f (absorbed %.2f)", old_energy, lf.energy, egy_absorb))
    end
  end
end