
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

    ## TODO I updated this function signature so I need to update everywhere it is used.
    #
    # Chucks-MacBook-Pro-14:~/git/lifeforms] grep -rs 'TestFactory.species' .
    # ./spec/model/lifeform_spec.rb:  let(:species) { TestFactory.species }
    # ./spec/model/lifeform_spec.rb:      s0 = TestFactory.species("species 0")
    # ./spec/model/lifeform_spec.rb:      s1 = TestFactory.species("species 1")
    # ./spec/model/lifeform_spec.rb:      s0 = TestFactory.species("species 0")
    # ./spec/model/lifeform_spec.rb:      s1 = TestFactory.species("species 1")
    # ./spec/model/env_stat_spec.rb:  let(:plant) { TestFactory.species('Plant') }
    # ./spec/model/env_stat_spec.rb:  let(:grazer) { TestFactory.species('Grazer') }
    # ./spec/sim/skill/eat_spec.rb:  let(:species_plant) { TestFactory.species('Plant') }
    # ./spec/sim/skill/eat_spec.rb:  let(:species_grazer) { TestFactory.species('Grazer') }
    # ./spec/sim/skill/move_to_food_spec.rb:  let(:species_plant) { TestFactory.species('Plant') }
    # ./spec/sim/skill/move_to_food_spec.rb:  let(:species_grazer) { TestFactory.species('Grazer') }
    # ./spec/sim/zoo/_base_spec.rb:  let(:species) { TestFactory.species(sname, TestAnimal) }
    # ./spec/helpers/test_factory.rb:    attrs[:species_id] = TestFactory.species.id unless attrs.key?(:species_id)
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