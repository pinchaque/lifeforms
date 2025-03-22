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

    def self.observations
      {
        env_energy: Obs::EnvEnergy
      }
    end

    def self.energy_absorb(ctx)
      Obs::EnvEnergy.calc(ctx) * ctx.value(:energy_absorb_perc)      
    end

    # Adds our absorbable energy to the lifeform's energy stores. This is
    # the total provided by the environment, minus that excluded by overlaps,
    # times the absorbtion percentage. Returns the new energy level.
    def self.eval(ctx)
      lf = ctx.lifeform
      old_energy = lf.energy
      egy_absorb = self.energy_absorb(ctx)
      lf.energy += egy_absorb
      lf.save
      Log.trace(sprintf("[EnvEnergy] Energy changed from %.2f to %.2f (absorbed %.2f)", old_energy, lf.energy, egy_absorb))
      lf.energy
    end
  end
end