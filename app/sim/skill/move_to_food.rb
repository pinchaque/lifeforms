module Skill
  class MoveToFood < Base

    def self.param_defs
      [
        ParamDefNormal(
          id: :move_dist,
          desc: "Total distance the lifeform can move in a turn",
          mean: 5.0,
          stddev: 0.5
        ),
        ParamDefNormal(
          id: :move_energy,
          desc: "Energy used per unit distance moved",
          mean: 3.0,
          stddev: 0.5
        ),
      ]
    end

    def self.observations
      {
        #food_dist: Obs::FoodDist
      }
    end

    # calculates the max distance the lifeform can move as limited by its 
    # available energy and how much it uses to move
    def self.max_dist_energy_limited(ctx)
      ctx.lifeform.energy / ctx.value(:move_energy)
    end

    # The max distance this lifeform can move in a turn. This is the lesser of
    # its "move_dist" parameter and how much it can move given the energy it has
    # left.
    def self.max_dist(ctx)
      [max_dist_energy_limited(ctx), ctx.value(:move_dist)].min
    end

    # Moves the lifeform as far as it can towards the nearest prey. Returns the
    # distance moved.
    def self.eval(ctx)
      lf = ctx.lifeform

      species_name = "Plant"
      species = Species.where(name: species_name).first
      if species.nil?
        Log.error("[MoveToFood] Couldn't find species", lf: lf, name: species_name)
        return 0.0
      end

      # We select the prey that will give us the most energy after paying the
      # cost to move there. 
      # Net energy = other.energy - (dist_to_other * energy_per_dist)
      lf_prey = lf.find_others_ds.
        where(species_id: species.id).
        reverse(Sequel.lit("lifeforms.energy - (sqrt(((? - lifeforms.x) ^ 2) + ((? - lifeforms.y) ^ 2)) * ?)", 
          lf.x, lf.y, ctx.value(:move_energy))).
        first

      if lf_prey.nil?
        Log.trace("[MoveToFood] Couldn't find any prey", lf: lf)
        return 0.0
      end
      
      # Log.trace("[MoveToFood] My Location", lf: lf, x: lf.x, y: lf.y)
      # Log.trace("[MoveToFood] Prey Found", lf: lf, name: lf_prey.name, x: lf_prey.x, y: lf_prey.y)

      coord_lf = lf.coord
      coord_prey = lf_prey.coord

      # figure out the angle and distance to the prey
      vec_to_prey = coord_prey - coord_lf

      #Log.trace("[MoveToFood] vec_to_prey", lf: lf, x: vec_to_prey.x, y: vec_to_prey.y, r: vec_to_prey.r, ang: vec_to_prey.ang)

      # max amount we can move this turn
      max_move_dist = max_dist(ctx)

      # actual move distance is lesser of where the prey is and our max dist
      actual_move_dist = [vec_to_prey.r, max_move_dist].min

      #Log.trace("[MoveToFood] Dist calc", lf: lf, max_move_dist: max_move_dist, prey_dist: vec_to_prey.r, actual_move_dist: actual_move_dist)

      # this is the coord we're moving to - same angle as the vector but the
      # distance is tempered by our limitations
      coord_lf_new = coord_lf + Coord.polar(actual_move_dist, vec_to_prey.ang)

      #Log.trace("[MoveToFood] coord_lf_new", lf: lf, x: coord_lf_new.x, y: coord_lf_new.y, r: coord_lf_new.r, ang: coord_lf_new.ang)

      energy_used = actual_move_dist * ctx.value(:move_energy)

      old_energy = lf.energy
      lf.energy -= energy_used
      # we shouldn't need to limit to bounds, but just in case...
      lf.x = [[0, coord_lf_new.x].max, ctx.env.width].min
      lf.y = [[0, coord_lf_new.y].max, ctx.env.height].min
      lf.save
      Log.trace("[MoveToFood] Moved towards prey", lf: lf,
        start: coord_lf.to_s, end: coord_lf_new.to_s, prey: coord_prey.to_s,
        egy_before: old_energy, egy_after: lf.energy, egy_used: energy_used,
        dist_moved: actual_move_dist, dist_prey: vec_to_prey.r)
      actual_move_dist
    end
  end
end