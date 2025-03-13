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
    # lf.repro_threshold = 60.0
    # lf.repro_num_offspring = 4
    # lf.repro_energy_inherit_perc = 0.95

    class Action
      def initialize(parent)
        @parent = parent
      end
    
      # Generates num offspring each with the specified energy
      def generate(energy, num = 1)
        children = []
        (0...num).each do
          child = @parent.create_child
          yield child if block_given? 
          children << child unless block_given?
        end
        block_given? ? nil : children
      end
    end
  end
end