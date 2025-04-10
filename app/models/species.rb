class Species < Sequel::Model(:species)
  plugin :timestamps, :force => true, :update_on_create => true

  # Returns the factory class used to generate Lifeforms of this Species
  def fact_class
    class_from_name(self.class_name)
  end

  # Returns instance of the factory class used ot generate Lifeforms of this Species
  def fact(env)
    fact_class.new(env, self)
  end

  # Returns a new and unsaved Lifeform instance of this Species for the
  # specified environment
  def gen_lifeform(env)
    fact(env).gen
  end
end