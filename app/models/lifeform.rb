require 'json'

class Lifeform < Sequel::Model
  plugin :after_initialize
  plugin :timestamps, :force => true, :update_on_create => true

  attr_reader :skills, :params, :observations
  attr_accessor :program

  #####################################################################
  # Sequel ORM hooks
  #####################################################################

  def after_initialize
    @skills = SkillSet.new if @skills.nil?
    @params = ParamSet.new if @params.nil?
    @observations = {} if @observations.nil?
    @program = Expr::True.new if @program.nil?

    # marshal this object's data from obj_data if it exists
    unless obj_data.nil?
      h = JSON.parse(obj_data, {symbolize_names: true})
      objdata_from_h(h)
    end
    super
  end

  def before_save
    # set the obj_data string to be JSON representation of this lifeform
    # object's data
    set(obj_data: JSON.generate(objdata_to_h))
    super
  end

  #####################################################################
  # Helper methods to get related objects
  #####################################################################

  # Returns the Environment of which this lifeform is a part
  def env
    Environment.where(id: environment_id).first  
  end

  def species
    Species.where(id: species_id).first
  end

  # Returns the parent Lifeform of this one, or nil if none
  def parent
    return nil if self.parent_id.nil?
    Lifeform.where(id: self.parent_id).first  
  end

  # Returns the Lifeforms that are children of this one, i.e. their parent_id
  # is set to this id. Returns empty array if none.
  def children
    Lifeform.where(parent_id: self.id).all
  end

  #####################################################################
  # Dataset filtering and fetching methods
  #####################################################################

  # Dataset that includes other Lifeforms in this environment (excluding self)
  def find_others_ds
    Lifeform.where(environment_id: self.environment_id).
      exclude(id: self.id)
  end

  # Returns the closest other lifeform that matches the given filters, e.g. 
  # of species_id
  def find_closest(**filters)
    ds = find_others_ds
    ds = ds.where(**filters) unless filters.empty?
    ds = order_dist_asc(ds)
    ds.first
  end

  # Returns the bounding box (square) around this lifeform
  def bounding_box
    r = self.radius
    return x - r, y - r, x + r, y + r
  end

  # Returns all other lifeforms in this environment that are potentially
  # overlapping with this one. We are guaranteed that there are no overlaps
  # that aren't in the return value. However, some of the returned Lifeforms
  # might not be actual overlaps. This function uses heuristics within a 
  # DB query to get the list, which should then be compared in more detail.
  def find_potential_overlaps
    # we identify potential overlaps by seeing if the bounding boxes of the
    # lifeforms are overlapping
    x0, y0, x1, y1 = bounding_box
    ds = find_others_ds.
      where(Sequel.lit('lifeforms.species_id = ?', [species_id])).
      where(Sequel.lit('lifeforms.x <= ? + (lifeforms.size / 2.0)', [x1])).
      where(Sequel.lit('lifeforms.x >= ? - (lifeforms.size / 2.0)', [x0])).
      where(Sequel.lit('lifeforms.y <= ? + (lifeforms.size / 2.0)', [y1])).
      where(Sequel.lit('lifeforms.y >= ? - (lifeforms.size / 2.0)', [y0]))
    ds.all
  end

  # Returns all other lifeforms in this environment that overlap this one.
  # Only returns lifeforms of the SAME SPECIES. Assumes all lifeforms are 
  # CIRCULAR.
  def find_overlaps
    find_potential_overlaps.select do |o|
      # we have a real overlap if the actual distance between the centers
      # is <= the sum of the radii of the two lifeforms
      dx = o.x - self.x
      dy = o.y - self.y
      dist = Math.sqrt(dx * dx + dy * dy)
      dist <= (self.size + o.size) / 2.0
    end
  end

  # Returns dataset filtering clauses that limit results to having their
  # coordinates <= the specified distance from this lifeform.
  def filter_lte_dist(ds, dist)
    # the bounding box that includes all lifeforms within dist of self
    x0 = self.x - dist
    x1 = self.x + dist
    y0 = self.y - dist
    y1 = self.y + dist
    
    # these clauses leverage the indexes on x and y
    ds.
    where(Sequel.lit('lifeforms.x <= ?', x1)).
    where(Sequel.lit('lifeforms.x >= ?', x0)).
    where(Sequel.lit('lifeforms.y <= ?', y1)).
    where(Sequel.lit('lifeforms.y >= ?', y0)).

    # now we filter by actual distance which isn't indexed
    where(Sequel.lit("sqrt(((? - lifeforms.x) ^ 2) + ((? - lifeforms.y) ^ 2)) <= ?", 
      self.x, self.y, dist))
  end

  # Finds all other lifeforms within the specified distance that also match
  # the specified filters. Returns dataset with results in ascending order by distance.
  def find_within_dist_ds(dist, **filters)
    ds = find_others_ds
    ds = filter_lte_dist(ds, dist)
    ds = ds.where(**filters) unless filters.empty?
    order_dist_asc(ds)
  end

  # Finds all other lifeforms within the specified distance that also match
  # the specified filters. Returns all results in ascending order by distance.
  def find_within_dist(dist, **filters)
    find_within_dist_ds(dist, **filters).all
  end

  # Orders dataset in ascending order by distance from this lifeform
  def order_dist_asc(ds)
    # Optimization: don't bother taking the sqrt because it doesn't change the sorting
    ds.order(Sequel.lit("((? - lifeforms.x) ^ 2) + ((? - lifeforms.y) ^ 2)", self.x, self.y))
  end

  #####################################################################
  # Basic calculations
  #####################################################################

  # Returns radius of the circle for this lifeform
  def radius
    self.size / 2.0
  end
  
  # Returns area of the lifeform assuming circle of diameter "size"
  def area
    Math::PI * (radius ** 2.0)
  end

  # Returns Coord object representing location of this lifeform
  def coord
    Coord.xy(self.x, self.y)
  end

  # Returns instance of the function to use for energy calculations
  def energy_fn
    EnergyFn.new(self.energy_exp, self.energy_base)
  end

  # Returns the total metabolic energy needed for a timestep based on the 
  # current lifeform size.
  def metabolic_energy
    energy_fn.energy(self.size)
  end

  #####################################################################
  # Marshalling / Unmarshalling
  #####################################################################

  # Converts this lifeform object's extra data into a hash
  def objdata_to_h
    {
      params: @params.marshal,
      skills: @skills.marshal,
      program: @program.marshal
    }
  end

  # Populates this lifeform object's extra data from a hash
  def objdata_from_h(h)
    @params = ParamSet.unmarshal(h[:params])
    @skills = SkillSet.unmarshal(h[:skills])
    @program = Expr.unmarshal(h[:program])
    @skills.skills.each { |id, s| add_obs(s) } # add observations (they aren't marshaled)
  end

  #####################################################################
  # Lifecycle management
  #####################################################################

  # Creates and returns a new Lifeform object that is the child of this one.
  # Attriutes are inherited from the parent where that makes sense. No genetic
  # mutations take place - those must be done afterwards.
  def create_child
    c = Lifeform.new

    # basic attributes that get inherited as is
    c.environment_id = self.environment_id
    c.species_id = self.species_id
    c.initial_size = self.initial_size
    c.x = self.x
    c.y = self.y
    c.energy_base = self.energy_base
    c.energy_exp = self.energy_exp

    # copy params, skills, program
    c.objdata_from_h(self.objdata_to_h)

    # these data are updated for new children
    c.parent_id = self.id
    c.created_step = env.time_step
    c.size = self.initial_size
    c.energy = 0.0
    c.set_random_name
    c.died_step = nil
    c.generation = self.generation + 1

    c
  end

  # Mutates this lifeform as part of the evolutionary process
  def mutate
    @params.mutate

    # TODO: need to mutate skills and/or program
  end

  # Mark that this lifeform has been born, adjusting data members as needed
  def mark_born
    self.created_step = env.time_step
    self
  end

  # Mark that this lifeform has died, adjusting data members as needed
  def mark_dead
    self.died_step = env.time_step
    self
  end

  # True if this lifeform is alive
  def is_alive?
    self.died_step.nil?
  end

  # True if this lifeform is dead
  def is_dead?
    !is_alive?
  end

  # Selects a random name for this lifeform.
  def set_random_name
    self.name = (NameParts::LF_DESCRIPTORS.sample.capitalize + " " + NameParts::LF_GIVENS.sample.capitalize).strip
  end

  # Sets this lifeform's x, y coordinates to be a random value within the
  # associated environment.
  def set_loc_random
    self.x = Random.rand(0.0..(env.width).to_f)
    self.y = Random.rand(0.0..(env.height).to_f)
  end

  # Sets this lifeform's x, y coordinates to be a random location that is dist
  # away from the specified coordinates. If the selected location is outside
  # the bounds of the environment then it is placed on the environment
  # boundary.
  def set_loc_dist(x, y, dist)
    # random angle in radians
    ang = Random.rand(0.0..2.0*Math::PI)

    # convert polar to cartesian
    dx = dist * Math.cos(ang)
    dy = dist * Math.sin(ang)

    # limit to canvas bounds
    xnew = x + dx
    xnew = 0.0 if xnew < 0.0
    xnew = env.width if xnew > env.width
    
    ynew = y + dy
    ynew = 0.0 if ynew < 0.0
    ynew = env.height if ynew > env.height

    self.x = xnew
    self.y = ynew
  end

  #####################################################################
  # Logging & Debugging
  #####################################################################

  def to_s
    loc_str = "(" + [x, y].map{ |a| sprintf("%.2f", a)}.join(", ") + ")"
    sprintf("%s %s %s energy:%.2f size:%.2f loc:%s", id, species.name, name, energy, size, loc_str)
  end

  def log_self(level = Scribe::Level::TRACE)
    parent = self.parent
    parent_str = parent.nil? ? 'NONE' : "#{parent.id} #{parent.name}"
    log(level, '[Data]', id: self.id, species: species.name, 
      created_step: self.created_step, parent: parent_str, 
      energy_base: self.energy_base, energy_exp: self.energy_exp)
    log(level, @skills.to_s)
    log(level, @params.to_s)
    log(level, '[Program] ' + @program.to_s)
    log(level, '[Attrs]', **attrs)

    ctx = self.context
    obs_h = @observations.to_h { |id, o| [id, o.calc(ctx)] }
    log(level, '[Observations]', **obs_h)
  end

  # outputs trace log message with this lifeform and additional context
  def log(level, msg, **ctx)
    Log.log(level, msg, lf: self, **ctx)
  end
  
  # outputs trace log message with this lifeform and additional context
  def log_trace(msg, **ctx)
    log(Scribe::Level::TRACE, msg, lf: self, **ctx)
  end

  #####################################################################
  # Frontend interaction data
  #####################################################################

  # Returns a hash of data for this lifeform that is used to render it visually
  def render_data
    {
      id: self.id,
      x: self.x,
      y: self.y,
      species: species.name,
      name: self.name,
      size: self.size,
      energy: self.energy,
      generation: self.generation
    }
  end

  #####################################################################
  # Simulation-related methods
  #####################################################################

  def register_skill(s)
    s.generate_params do |prm|
      @params.add(prm)
    end
    add_obs(s)
    @skills.add(s)
  end

  def clear_skills
    @skills.clear
    @params.clear
    @observations.clear
  end

  # Adds observations from the specified Skill to this Lifeform
  def add_obs(s)
    s.observations.each do |id, klass|
      @observations[id.to_sym] = klass
    end
  end

  def context
    Context.new(self)
  end

  # Gets a hash of "attributes" - characteristics of this lifeform that can
  # be used in expressions
  def attrs
    {
      lf_energy: self.energy,
      lf_age: env.time_step - self.created_step,
      lf_metabolic_energy: self.metabolic_energy,
      lf_size: self.size,
      lf_generation: self.generation,
      lf_initial_size: self.initial_size,
      lf_x: self.x,
      lf_y: self.y,
  }
  end


  def run_step
    log_trace("Step #{env.time_step} starting...")
    log_self

    # deduct our metabolic energy
    egy_before = self.energy
    meta = metabolic_energy
    self.energy = [self.energy - metabolic_energy, 0.0].max
    save
    log_trace("Deducted metabolic energy", metabolic: meta, egy_before: egy_before, egy_after: self.energy)

    # execute our program
    log_trace("Program execution starting...")
    program.eval(context)
    log_trace("Program execution done", energy: self.energy, size: self.size)

    # Marks this organism as dead if it is out of energy
    if ((self.energy <= 0.0) || (self.size < self.initial_size))
      mark_dead
      log_trace("DIED", energy: self.energy, size: self.size, initial_size: self.initial_size)
    end

    log_trace("Step #{env.time_step} complete")

    self
  end
end