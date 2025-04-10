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

  # Helper method to return the count of living members of this species
  def count_lifeforms
    Lifeform.where(environment_id: self.environment_id, species_id: self.species_id, died_step: nil).count
  end

  # Runs this Spawner to create Lifeforms for the Environment
  def run
    n = count_lifeforms
    num_gen = 0
    spawn_type = "none"
    fact = species.fact(env)

    # if we're below our min, then just bring ourselfs up to that
    if !min_lifeforms.nil? && (n < min_lifeforms)
      while n < min_lifeforms
        fact.gen.save
        n += 1
        num_gen += 1
        spawn_type = "min_lifeforms"
      end
    # else if we're below our max, we probabilistically generate one
    elsif max_lifeforms.nil? || (n < max_lifeforms)
      if p_spawn > Random.rand(0.0...1.0)
        fact.gen.save
        num_gen += 1
        spawn_type = "probabilistic"
      end
    end

    env.log_debug("Spawning complete", species: species.name, type: spawn_type, num_gen: num_gen)
    num_gen
  end
end