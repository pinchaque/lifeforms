module Skill
  class Reproduce < Base
    def self.param_defs
      [
        ParamDefNormalInt(
          id: :repro_num_offspring,
          desc: "How many offspring the lifeform creates upon reproduction",
          mean: 4,
          stddev: 1
        ),
        ParamDefNormalPerc(
          id: :repro_energy_inherit_perc,
          desc: "What percentage of this lifeform's energy reserves it gives to its offspring upon reproduction",
          mean: 0.95,
          stddev: 0.1
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

      Log.trace("Creating #{num_offspring} children with #{child_egy} energy each...")

      # Create the children
      (0...num_offspring).each do |i|
        child = lf.create_child
        child.energy = child_egy
        child.set_loc_dist(lf.x, lf.y, lf.radius)
        child.save
        Log.trace("  - #{child.to_s}")
      end

      # Subtract the energy we gave to the offspring
      lf.energy -= offspring_energy_tot(ctx)
      lf.save

      lf.energy
    end
  end
end