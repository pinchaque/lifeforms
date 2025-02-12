class EnvironmentFactory
  attr_accessor :width, :height, :energy_rate

  def initialize
    @width = 100.0
    @height = 100.0
    @energy_rate = 5.0
  end

  def gen
    Environment.new(width: @width, height: @height, energy_rate: @energy_rate)
  end
end