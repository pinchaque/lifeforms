class Simulation

  def initialize(w, h)
    @env = Environment.new(width: w, height: h, time_step: 0).save
  end

  # Returns all lifeforms in this environment.
  def lifeforms
    Lifeforms.where(environment_id: @env.id).all
  end

  # Adds a lifeform to the specified lifeform_loc.
  def add_lifeform(l, loc)
    abort "Lifeform #{l.to_s} already added to environment #{l.environment_id}" unless l.environment_id.nil?
    l.environment_id = id
    l.save

    # save the location - will error if this is not unique
    loc.environment_id = id
    loc.lifeform_id = l.id
    loc.save
  end

  # Adds a lifeform to the environment at a random location within it.
  def add_lifeform_rnd(l)
    add_lifeform(l, LifeformLoc.random(width, height))
  end

  # Adds a lifeform at a random direction the specified distance from another 
  # location. Lifeform will be placed at the edge of the environment if the
  # distance would put it over the boundary.
  def add_lifeform_dist(l, loc, dist)
    add_lifeform(l, LifeformLoc.at_dist(width, height, loc, dist))
  end

  def run_step
    lifeforms.shuffle.each do |l|
      l.run_step(@env)
    end
    @env.time_step += 1
    @env.save
  end

  def to_s
    @env.to_s
  end
end