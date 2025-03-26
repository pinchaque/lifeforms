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
      Log.trace(sprintf("[Shrink] Size has decreased by %0.2f%%", shrink_perc * 100.0),
        lf: lf, size_before: old_size, size_after: lf.size, 
        meta_before: old_meta, meta_after: lf.metabolic_energy)

      lf.size
    end
  end
end