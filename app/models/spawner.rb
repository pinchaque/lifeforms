class Spawner < Sequel::Model
  plugin :timestamps, :force => true, :update_on_create => true

  # Helper to return the Environment for this Spawner
  def env
    Environment.where(id: self.environment_id).first
  end

  # Helper to return the Species for this Spawner
  def species
    Species.where(id: self.species_id).first
  end

  # Runs this Spawner to create Lifeforms for the Environment
  def run
    # TODO implement
  end
end