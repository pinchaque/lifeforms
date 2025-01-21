require 'json'

class Lifeform  < Sequel::Model
  def before_save
    # set the obj_data string to be JSON representation of this lifeform
    # object's data
    obj_data = JSON.generate(marshal_to_h)
    super
  end

  # Override object population to also call marshal_from_h to populate data
  # in the subclasses
  def call(values)
    ret = super(values)
    marshal_from_h(JSON.parse(obj_data))
    ret
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
  end

  def run_step(env)
    # nothing to do in base class
  end

  def species
    Species.where(id: species_id).first
  end

  def loc
    LifeformLoc.where(environment_id: environment_id, lifeform_id: id).first
  end

  def to_s
    l = loc
    loc_str = l.nil? ? "(?, ?)" : l.to_s
    sprintf("%s %s energy:%.2f size:%.2f loc:%s", species.name, name, energy, size, loc_str)
  end
end