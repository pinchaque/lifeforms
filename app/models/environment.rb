class Environment  < Sequel::Model
  plugin :timestamps, :force => true, :update_on_create => true

  def before_validation
    self.time_step = 0 if self.time_step.nil?
    set_random_name if self.name.nil?
    super
  end

  # Returns all lifeforms in this environment.
  def lifeforms
    lifeforms_ds.all
  end
  
  # Returns Sequel Dataset for all lifeforms in this environment.
  def lifeforms_ds
    Lifeform.where(environment_id: id)
  end

  # Adds a lifeform to the specified lifeform_loc.
  def add_lifeform(l, loc)
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
  def add_lifeform_dist(lf_ref, lf_new, dist)
    # first we get the location of the reference lifeform
    loc = LifeformLoc.where(environment_id: self.id, lifeform_id: lf_ref.id).first

    add_lifeform(lf_new, LifeformLoc.at_dist(width, height, loc, dist))
  end

  def run_steps(n)
    (0...n).each { |i| run_step }
  end

  def run_step
    DB.transaction do
      lifeforms.all.shuffle.each do |l|
        l.run_step.save
      end
      self.time_step += 1
      save
    end
  end

  def to_s_detailed
    to_s + "\n" + lifeforms.order(:name).map{ |l| "  * #{l.to_s}" }.join("\n")
  end

  def to_s
    sprintf("id:%s name:%s created:%s timestep:%d lifeforms:%d size:(%d,%d)",
      id, name, created_at, time_step, lifeforms.count, width, height)
  end

  def render_data
    lifeforms.map { |l| l.render_data }
  end

  def set_random_name
    self.name = (NameParts::ENV_ADJ.sample.capitalize + " " + NameParts::ENV_TYPE.sample.capitalize).strip
  end
end