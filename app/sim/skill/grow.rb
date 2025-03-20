module Skill
  class Grow < Base

    def self.param_defs
      [
        ParamDefNormalPerc(
          id: :grow_perc,
          desc: "Percentage to grow when this skill is executed",
          mean: 0.05,
          stddev: 0.005
        ),
      ]
    end

    # Grows the lifeform by grow_perc. Returns the new size.
    def self.eval(ctx)
      lf = ctx.lifeform
      grow_perc = ctx.value(:grow_perc)
      old_size = lf.size
      lf.size *= (1.0 + grow_perc)
      lf.save
      Log.trace(sprintf("[Grow] Growing from %.2f to %.2f (%0.2f%%)", old_size, lf.size, grow_perc * 100.0))
      lf.size
    end
  end
end