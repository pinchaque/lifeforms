class MockEnv
  
end

class MockLifeform
  attr_accessor :env, :skills, :params, :attrs, :observations
  attr_accessor :size, :energy

  def initialize
    @skills = Hash.new
    @params = Hash.new
    @attrs = Hash.new
    @observations = Hash.new
    @env = MockEnv.new
  end

  def register_skill(s)
    s.generate_params do |prm|
      @params[prm.id] = prm
    end
    @skills[s.id] = s
  end
end

class MockAnimal < Zoo::Base
  def set_attrs(ta)
    ta.energy = 1.23
  end
end