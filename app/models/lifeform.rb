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
      name: other.name
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

  def loc
    LifeformLoc.where(environment_id: environment_id, lifeform_id: id).first
  end

  def env
    Environment.where(id: environment_id).first
  end

  def to_s
    l = loc
    loc_str = l.nil? ? "(?, ?)" : l.to_s
    sprintf("%s %s energy:%.2f size:%.2f loc:%s", species.name, name, energy, size, loc_str)
  end

  def set_random_name
    self.name = (NameParts::DESCRIPTORS.sample.capitalize + " " + NameParts::GIVENS.sample.capitalize).strip
  end

  # Returns a hash of data for this lifeform that is used to render it visually
  def render_data
    l = loc
    {
      id: self.id,
      x: l.x,
      y: l.y,
      species: species.name,
      name: self.name,
      size: self.size,
      energy: self.energy,
      generation: self.generation
    }
  end
end