# Class that calculates the size changes a lifeform will make as it uses energy
# for growth or shrinks to create more energy.
class GrowthFn
  # Exponent to use when calculating the energy needed to scale up by one. 
  # Typically this would be >1 so that as the lifeform grows it will require
  # more and more energy to keep growing.
  attr_accessor :scale_factor

  def initialize(scale_factor)
    raise "scale_factor cannot be 0" if scale_factor == 0
    @scale_factor = scale_factor
  end

  def root
    1.0 / @scale_factor
  end

  # Returns the size by which the lifeform will grow/shrink when moving from 
  # energy_start to energy_end. If energy_end > energy_start then this is 
  # growth and the function will return a positive number. 
  # energy_end < energy_start means shrinkage and return will be negative.
  # Only non-negative energy values are allowed.
  def size_delta(energy_start, energy_end)
    raise "energy_start (#{energy_start}) cannot be < 0" if energy_start < 0.0
    raise "energy_end (#{energy_end}) cannot be < 0" if energy_end < 0.0
    (energy_end ** root) - (energy_start ** root)
  end
end