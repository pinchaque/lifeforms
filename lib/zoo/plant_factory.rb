class PlantFactory
  attr_accessor :energy_min, :energy_max
  attr_accessor :growth_rate, :energy_split

  def initialize
    @energy_min = 10.0
    @energy_max = 20.0
    @energy_split = 30.0
    @growth_rate = 0.2
  end
  
  def gen
    p = Plant.new
    p.energy = Random.rand(@energy_min..@energy_max)
    p.growth_rate = @growth_rate
    p.energy_split = @energy_split
    p
  end
end