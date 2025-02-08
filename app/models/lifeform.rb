require 'json'

class Lifeform < Sequel::Model
  plugin :single_table_inheritance, :class_name
  plugin :after_initialize
  plugin :timestamps, :force => true, :update_on_create => true

  def after_initialize
    # marshal this objects data from obj_data if it exists
    unless obj_data.nil?
      h = JSON.parse(obj_data, {symbolize_names: true})
      marshal_from_h(h)
    end
    super
  end

  def before_save
    # set the obj_data string to be JSON representation of this lifeform
    # object's data
    set(obj_data: JSON.generate(marshal_to_h))
    super
  end

  # Set to true to enable additional logging
  def debug
    false
  end

  # Converts this lifeform object's extra data into a hash
  def marshal_to_h
    Hash.new
  end

  # Populates this lifeform object's extra data from a hash
  def marshal_from_h(h)
    # do nothing - only used in child classes
  end

  # Copies the attributes of another lifeform into this one
  def copy_from(other)      
    set(environment_id: other.environment_id,
      species_id: other.species_id,
      energy: other.energy,
      size: other.size,
      name: other.name,
      x: other.x,
      y: other.y
    )
    marshal_from_h(other.marshal_to_h)
  end

  def run_step
    # nothing to do in base class
    self
  end

  def species
    Species.where(id: species_id).first
  end

  def env
    Environment.where(id: environment_id).first
  end

  def to_s
    loc_str = "(" + [x, y].map{ |a| sprintf("%.2f", a)}.join(", ") + ")"
    sprintf("%s %s %s energy:%.2f size:%.2f loc:%s", id, species.name, name, energy, size, loc_str)
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
end