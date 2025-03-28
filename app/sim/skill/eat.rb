module Skill
  class Eat < Base

    def self.param_defs
      [
        ParamDefNormal(
          id: :eat_max_energy,
          desc: "Max energy lifeform can consume in a turn",
          mean: 60.0,
          stddev: 12.0,
          min: 1.0
        ),
      ]
    end

    # Eats from the closest Plant whose location is within our radius. 
    # Reduces that Plant's energy by the amount eaten and returns that amount.
    def self.eval(ctx)
      lf = ctx.lifeform

      species_name = "Plant"
      species = Species.where(name: species_name).first
      if species.nil?
        Log.error("[Eat] Couldn't find species", lf: lf, name: species_name)
        return 0.0
      end

      # get closest prey within our eating distance (radius)
      lf_prey = lf.find_within_dist_ds(lf.radius, species_id: species.id).first

      if lf_prey.nil?
        Log.trace("[Eat] Couldn't find any prey within eating range", lf: lf, distance: lf.radius)
        return 0.0
      end

      coord_lf = lf.coord
      coord_prey = lf_prey.coord
      vector_to_prey = coord_prey - coord_lf
      dist_to_prey = vector_to_prey.r

      if dist_to_prey > lf.radius
        # shouldn't hit this given above find_within_dist, but just in case...
        Log.trace("[Eat] Nearest prey was too far away", lf: lf, prey: lf_prey.to_s, dist: dist_to_prey)
        return 0.0        
      end

      # the amount of energy we consume is the lesser of (a) our max we can
      # consume in a turn; and (b) the prey's current energy level
      energy_consumed = [ctx.value(:eat_max_energy), lf_prey.energy].min

      old_energy = lf.energy

      lf.energy += energy_consumed
      lf.save

      lf_prey.energy -= energy_consumed
      lf_prey.save

      Log.trace("[Eat] Ate from prey", lf: lf,
        egy_before: old_energy, egy_after: lf.energy, egy_consumed: energy_consumed,
        prey: lf_prey.to_s)
      energy_consumed
    end
  end
end