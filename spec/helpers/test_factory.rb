
# Contains several helper functions to generate saved objects in the db useful
# for unit tests.
class TestFactory
  def self.species(**attrs)
    defaults = {
      name: "Test Lifeform",
      class_name: "MockAnimal"
    }
    h = defaults.merge(attrs)
    s = Species.where(name: h[:name]).first    
    s = Species.new(**h).save if s.nil?
    s
  end

  def self.env(**attrs)
    defaults = {
      width: 100, 
      height: 100, 
      time_step: 0, 
      energy_rate: 5.0
    }
    Environment.new(**(defaults.merge(attrs))).save
  end

  def self.lifeform(environment_id:, **attrs)
    # use our test species if none specified
    attrs[:species_id] = TestFactory.species.id unless attrs.key?(:species_id)
    defaults = {
      environment_id: environment_id,
      created_step: 0,
      energy: 10.0,
      size: 1.0,
      generation: 2,
      initial_size: 0.2,
      x: 2.22,
      y: 3.33,
      energy_base: 1.0,
      energy_exp: 3.0
    }
    l = Lifeform.new(**(defaults.merge(attrs)))
    l.set_random_name
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
  def self.skill(ret, obs = {}, params = [:param1, :param2])
    Class.new(Skill::Base) do
      @ret = ret
      @obs = obs
      @params = params

      def self.eval(ctx)
        @ret
      end

      def self.observations
        @obs
      end

      def self.param_defs
        @params.map { |p| ParamDefNormalPerc(id: p, mean: 0.5, stddev: 0.2, desc: "Test param #{p}") }
      end
    end
  end
end