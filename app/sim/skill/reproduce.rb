module Skill
  class Reproduce < Base
    def actions
      [
        :reproduce
      ]
    end

    def observations
      [
      ]
    end

    def params
      [
        # Energy level at which the lifeform reproduces
        :repro_threshold,

        # How many offspring the lifeform creates upon reproduction
        :repro_num_offspring,

        # What percentage of this lifeform's energy reserves it gives to its 
        # offspring upon reproduction.
        :repro_energy_inherit_perc,
      ]
    end
  end
end