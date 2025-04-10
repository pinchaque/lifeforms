class Species < Sequel::Model(:species)
  plugin :timestamps, :force => true, :update_on_create => true

  # Helper to return the environment for this species
  def env
    Environment.where(id: self.environment_id).first
  end

  # Returns the factory class used to generate Lifeforms of this Species
  def fact_class
    class_from_name(self.class_name)
  end

  # Returns a new and unsaved Lifeform instance of this Species.
  def gen_lifeform
    fact_class.new(env).gen
  end
end