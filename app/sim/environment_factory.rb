class EnvironmentFactory
  attr_accessor :width, :height, :energy_rate, :spawner_params

  def initialize
    @width = 100.0
    @height = 100.0
    @energy_rate = 10.0
    @spawner_params = {
      "Plant" => {
        p_spawn: 0.10,
        min_lifeforms: 4,
        max_lifeforms: 40
      },
      "Grazer" => {
        p_spawn: 0.20,
        min_lifeforms: 2,
        max_lifeforms: 20
      },
    }
  end

  # Creates and saves a new environment, returning the object.
  def create_env
    Environment.new(width: @width, height: @height, energy_rate: @energy_rate).save
  end

  # Creates and saves the Spawners for the specified environment.
  def create_spawners(env)
    @spawner_params.each do |sp_name, prms|
      sp = Species.where(name: sp_name).first
      throw "Failed to find species '#{sp_name}'" if sp.nil?
      Spawner.new(environment_id: env.id, species_id: sp.id, **prms).save
    end
  end

  # Creates and saves a new environment along with all the lifeform spanwers.
  # Returns the new environment.
  def gen
    env = create_env
    create_spawners(env)
    env
  end
end