module Skill
  class Reproduce < Base
    def self.param_defs
      [
        Skill.ParamDefNormalPerc(
          id: :repro_threshold,
          desc: "Energy level at which the lifeform reproduces",
          mean: 60.0,
          stddev: 0.5
        ),
        Skill.ParamDefNormalPerc(
          id: :repro_num_offspring,
          desc: "How many offspring the lifeform creates upon reproduction",
          mean: 4.0,
          stddev: 1.0
        ),
        Skill.ParamDefNormalPerc(
          id: :repro_energy_inherit_perc,
          desc: " What percentage of this lifeform's energy reserves it gives to its offspring upon reproduction",
          mean: 0.95,
          stddev: 0.1
        ),
      ]
    end

    # Total amount of energy to give to offspring when reproducing. This is
    # calculated based on the current energy reserves multiplied by the 
    # percentage we give to offspring.
    def self.offspring_energy_tot(ctx)
      perc(repro_energy_inherit_perc) * self.energy
    end

    # The amount of energy each offspring will get. This is simply the total
    # divided by the number of offspring
    def self.offspring_energy_each(ctx)
      offspring_energy_tot / repro_num_offspring
    end
    
    def self.exec(ctx)
      # Subtract the energy we're giving to the offspring
      self.energy -= offspring_energy_tot(ctx)
      save

      Log.trace("Creating #{repro_num_offspring} children...")

      r = Reproduce.new(self)
      r.generate(offspring_energy_each, repro_num_offspring) do |child|
        child.set_loc_dist(self.x, self.y, self.radius)
        child.save
        Log.trace("  - #{child.to_s}")
      end
      Log.trace(sprintf("After reproducing energy:%f", energy))      
    end
  end
end