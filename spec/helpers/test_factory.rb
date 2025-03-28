# Contains several helper functions to generate saved objects in the db useful
# for unit tests.
class TestFactory
  def self.species(name = "Test Lifeform")
    s = Species.where(name: name).first    
    s = Species.new(name: name).save if s.nil?
    s
  end

  def self.env(width = 100, height = 100, time_step = 0, energy_rate = 5.0)
    Environment.new(width: width, height: height, time_step: time_step, energy_rate: energy_rate).save
  end

  def self.lifeform(e, s)
    l = Lifeform.new
    l.environment_id = e.id
    l.species_id = s.id
    l.created_step = e.time_step
    l.energy = 10.0
    l.size = 1.0
    l.generation = 2
    l.initial_size = 0.2
    #l.name = "Incredible Juniper"
    l.set_random_name
    l.x = 2.22
    l.y = 3.33
    l.energy_base = 1.0
    l.energy_exp = 3.0
    l.mark_born
    l.save
    l
  end

  # Creates an Observation class that returns the specified value
  def self.obs(ret)
    Class.new(Obs::Base) do
      @ret = ret
      def self.calc(ctx)
        @ret
      end
    end
  end

  # Creates a Skill class that returns the specified string when exec is 
  # called. This returns an unnamed class, so for things to work you
  # need to assign the return of this function to a CamelCase class name
  # because that's how Skill.id is computed.
  def self.skill(ret, obs = {})
    Class.new(Skill::Base) do
      @ret = ret
      @obs = obs

      def self.eval(ctx)
        @ret
      end

      def self.observations
        @obs
      end

      def self.param_defs
        [
          ParamDefNormalPerc(id: :param1, mean: 0.5, stddev: 0.2, desc: "Test param 1"),
          ParamDefNormalPerc(id: :param2, mean: 0.5, stddev: 0.2, desc: "Test param 2"),
        ]
      end
    end
  end
end