require 'json'

class Lifeform < Sequel::Model
  plugin :after_initialize
  plugin :timestamps, :force => true, :update_on_create => true

  attr_reader :skills, :params, :observations
  attr_accessor :program

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

  # Returns radius of the circle for this lifeform
  def radius
    self.size / 2.0
  end
  
  # Returns area of the lifeform assuming circle of diameter "size"
  def area
    Math::PI * (radius ** 2.0)
  end

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

  def to_s
    loc_str = "(" + [x, y].map{ |a| sprintf("%.2f", a)}.join(", ") + ")"
    sprintf("%s %s %s energy:%.2f size:%.2f loc:%s", id, species.name, name, energy, size, loc_str)
  end

  def to_s_debug
    ctx = self.context    
    [
      to_s, 
      @skills.to_s, 
      @params.to_s, 
      '[Program] ' + @program.to_s,
      '[Observations] ' + @observations.keys.map { |id| "#{id}: #{@observations[id].calc(ctx)}"}.join(", ")
    ].join("\n")
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

  def register_skill(s)
    Log.trace("Registering Skill #{s.id}")
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

  # Returns instance of the function to use for energy calculations
  def energy_fn
    EnergyFn.new(self.energy_exp, self.energy_base)
  end

  # Gets a hash of "attributes" - characteristics of this lifeform that can
  # be used in expressions
  def attrs
    {
      lf_energy: self.energy,
      lf_age: self.created_step - env.time_step,
      lf_metabolic_energy: self.metabolic_energy,
      lf_size: self.size,
      lf_generation: self.generation,
      lf_initial_size: self.initial_size,
      lf_x: self.x,
      lf_y: self.y,
  }
  end

  # Returns the total metabolic energy needed for a timestep based on the 
  # current lifeform size.
  def metabolic_energy
    energy_fn.energy(self.size)
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
    ds = Lifeform.
      where(Sequel.lit('lifeforms.environment_id = ?', [environment_id])).
      where(Sequel.lit('lifeforms.species_id = ?', [species_id])).
      where(Sequel.lit('lifeforms.id != ?', [id])).
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

  def run_step
    Log.debug(to_s_debug)

    # execute our program
    program.eval(context)

    # deduct our metabolic energy
    self.energy = [self.energy - metabolic_energy, 0.0].max

    # Marks this organism as dead if it is out of energy
    mark_dead if self.energy <= 0.0

    self
  end
end