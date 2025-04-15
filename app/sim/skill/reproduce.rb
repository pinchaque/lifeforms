module Skill
  class Reproduce < Base
    def self.param_defs
      [
        ParamDefNormalInt(
          id: :repro_num_offspring,
          desc: "How many offspring the lifeform creates upon reproduction",
          mean: 3,
          stddev: 1
        ),
        ParamDefNormalPerc(
          id: :repro_energy_inherit_perc,
          desc: "What percentage of this lifeform's energy reserves it gives to its offspring upon reproduction",
          mean: 0.8,
          stddev: 0.1
        ),
        ParamDefNormalPerc(
          id: :repro_prog_mutate_perc,
          desc: "Percentage chance any given Expr will be mutated after reproduction",
          mean: 0.08,
          stddev: 0.01
        ),
      ]
    end

    # Total amount of energy to give to offspring when reproducing. This is
    # calculated based on the current energy reserves multiplied by the 
    # percentage we give to offspring.
    def self.offspring_energy_tot(ctx)
      perc(ctx.value(:repro_energy_inherit_perc)) * ctx.lifeform.energy
    end

    # The amount of energy each offspring will get. This is simply the total
    # divided by the number of offspring
    def self.offspring_energy_each(ctx)
      offspring_energy_tot(ctx) / ctx.value(:repro_num_offspring)
    end
    
    # Creates offspring for a lifeform and returns the energy left in the lifeform.
    def self.eval(ctx)
      lf = ctx.lifeform
      num_offspring = ctx.value(:repro_num_offspring)
      child_egy = offspring_energy_each(ctx)

      Log.trace("[Reproduce] Creating offspring...", lf: lf, num_offspring: num_offspring, offspring_egy: child_egy)

      # Create the children
      (0...num_offspring).each do |i|
        child = lf.create_child
        child.energy = child_egy
        child.set_loc_dist(lf.x, lf.y, lf.radius)
        child.params.mutate
        child.program = child.program.mutate(ctx, ctx.value(:repro_prog_mutate_perc))
        child.save
        Log.trace("[Reproduce]   - #{child.to_s}", lf: lf)
      end

      # Subtract the energy we gave to the offspring
      egy_before = lf.energy
      lf.energy -= offspring_energy_tot(ctx)
      lf.save

      Log.trace("[Reproduce] Parent energy reduced", lf: lf, egy_before: egy_before, egy_after: lf.energy)

      lf.energy
    end
  end
end