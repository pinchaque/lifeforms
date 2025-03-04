module Skill
  class EnvEnergy < Base
    def actions
      [
        :absorb
      ]
    end

    def observations
      [
        :area_clear
      ]
    end

    def params
      [
        # Percentage of the environmental energy available to this lifeform that it
        # actually absorbs
        :energy_absorb_perc,
      ]
    end
  end
end