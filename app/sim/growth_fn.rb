# Class that calculates the size changes a lifeform will make as it uses energy
# for growth or shrinks to create more energy. The formula encoded here is:
# s = (e / c) ^ (1 / f)
#   or
# e = c * (s ^ f)
# where:
#   s: Size
#   e: Energy
#   c: Energy it takes to grow from 0 to 1 unit of size (e_base)
#   f: Polynomial growth exponent (exp)
class GrowthFn
  # Exponent to use when calculating the energy needed to scale up by one. 
  # Must be > 0. Typically this would be >1 so that as the lifeform grows it 
  # will require more and more energy to keep growing.
  attr_accessor :exp

  # Base energy it takes to grow from size 0 to 1 
  attr_accessor :e_base

  def initialize(exp, e_base)
    raise "exp (#{exp}) cannot be <= 0" if exp <= 0.0
    raise "e_base (#{e_base}) cannot be < 0" if e_base < 0
    @exp = exp
    @e_base = e_base
  end

  # Exponent to use when taking the n'th-root of the energy to derive the 
  # size delta.
  def root
    1.0 / @exp
  end

  # Returns energy for given size
  def energy(size)
    raise "size (#{size}) cannot be < 0" if size < 0.0
    @e_base * (size ** @exp)
  end

  # Returns size for given energy
  def size(energy)
    raise "energy (#{energy}) cannot be < 0" if energy < 0.0
    (energy / @e_base) ** (1.0 / @exp)
  end

  # Returns the size by which the lifeform will grow/shrink when moving from 
  # energy_start to energy_end. If energy_end > energy_start then this is 
  # growth and the function will return a positive number. 
  # energy_end < energy_start means shrinkage and return will be negative.
  # Only non-negative energy values are allowed.
  def size_delta(energy_start, energy_end)
    raise "energy_start (#{energy_start}) cannot be < 0" if energy_start < 0.0
    raise "energy_end (#{energy_end}) cannot be < 0" if energy_end < 0.0
    size(energy_end) - size(energy_start)
  end
end