module Skill
  class Shrink < Base

    def self.param_defs
      [
        ParamDefNormalPerc(
          id: :shrink_perc,
          desc: "Shrink to this percentage of current size when this skill is executed",
          mean: 0.6,
          stddev: 0.1
        ),
      ]
    end

    # Shrinks the lifeform to shrink_perc of its current size, returning the
    # new size.
    def self.eval(ctx)
      lf = ctx.lifeform
      old_meta = lf.metabolic_energy
      shrink_perc = ctx.value(:shrink_perc)
      old_size = lf.size
      lf.size *= shrink_perc
      lf.save
      Log.trace(sprintf("[Shrink] Shrinking from %.2f to %.2f (%0.2f%%); metabolic energy went from %.2f to %.2f", 
        old_size, lf.size, shrink_perc * 100.0, old_meta, lf.metabolic_energy))
      lf.size
    end
  end
end