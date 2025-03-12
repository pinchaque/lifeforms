class MockEnv
  
end

class MockLifeform
  attr_accessor :env, :skills, :params

  def initialize
    @skills = Hash.new
    @params = Hash.new
    @env = MockEnv.new
  end

  def register_skill(s)
    s.generate_params do |prm|
      @params[prm.id] = prm
    end
    @skills[s.id] = s
  end
end