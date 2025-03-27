module Skill
  class Eat < Base

    def self.param_defs
      [
        ParamDefNormal(
          id: :eat_max_energy,
          desc: "Max energy lifeform can consume in a turn",
          mean: 40.0,
          stddev: 10.0,
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

      # TODO use a different query that doesn't look through whole environment, 
      # can use bounding box
      lf_prey = lf.find_closest(species_id: species.id)

      if lf_prey.nil?
        Log.trace("[Eat] Couldn't find any prey", lf: lf)
        return 0.0
      end

      coord_lf = lf.coord
      coord_prey = lf_prey.coord
      vector_to_prey = coord_prey - coord_lf
      dist_to_prey = vector_to_prey.r

      if dist_to_prey > lf.radius
        Log.trace("[Eat] Nearest prey was too far away", lf: lf, prey: lf_prey.to_s, dist: dist_to_prey)
        return 0.0        
      end

      # the amount of energy we consume is the lesser of (a) our max we can
      # consume in a turn; and (b) the prey's current energy level
      energy_consumed = [ctx.value(:eat_max_energy), lf_prey.energy].min

      # Log.trace("debug", lf: lf, eat_max_energy: ctx.value(:eat_max_energy),
      #   prey_energy: lf_prey.energy, energy_consumed: energy_consumed)

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