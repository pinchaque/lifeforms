module Skill
  class Grow < Base
    def actions
      [
        :grow
      ]
    end

    def observations
      [
      ]
    end

    def params
      [
        # Target percentage of the incoming energy that this lifeform tries to 
        # move into its energy stores. It will grow or shrink to try to achieve
        # this percentage
        :energy_reserve_perc
      ]
    end
  end
end