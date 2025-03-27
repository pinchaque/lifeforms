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
      ctx.lf.energy / ctx.value(:move_energy)
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

      lf_prey = lf.find_closest("Plant")

      if lf_prey.nil?
        Log.trace("[MoveToFood] Couldn't find any prey", lf: lf)
        return 0.0
      end

      coord_lf = lf.coord
      coord_prey = lf_prey.coord

      # figure out the angle and distance to the prey
      vector_to_prey = coord_prey - coord_lf

      # max amount we can move this turn
      max_move_dist = max_dist(ctx)

      # actual move distance is lesser of where the prey is and our max dist
      actual_move_dist = [vector_to_prey.r, max_move_dist].min

      # this is the coord we're moving to - same angle as the vector but the
      # distance is tempered by our limitations
      coord_lf_new = Coord.polar(actual_move_dist, vector_to_prey.ang)

      energy_used = coord_lf_new.r * ctx.value(:move_energy)

      old_energy = lf.energy
      lf.energy -= energy_used
      lf.x = coord_lf_new.x
      lf.y = coord_lf_new.y
      lf.save
      Log.trace("[MoveToFood] Moved towards prey", lf: lf,
        start: coord_lf.to_s, end: coord_lf_new.to_s, prey: coord_prey.to_s,
        egy_before: old_energy, egy_after: lf.energy, egy_used: energy_used,
        dist_moved: actual_move_dist, dist_prey: vector_to_prey.r)
      actual_move_dist
    end
  end
end