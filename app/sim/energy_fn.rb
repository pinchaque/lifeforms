# Class that calculates the energy a lifeform uses at a given size. The 
# polynomial formula used is:
# s = (e / e_base) ^ (1 / exp)
#   or
# e = e_base * (s ^ exp)
# where:
#   s: Size
#   e: Energy
#   e_base: Energy it takes to grow from 0 to 1 unit of size
#   exp: Polynomial energy usage exponent
class EnergyFn
  # Exponent to use when calculating the energy needed. Must be > 0. Typically
  # this would be >1 to damper growth as the lifeform gets larger.
  attr_accessor :exp

  # Base energy it takes to grow from size 0 to 1 
  attr_accessor :e_base

  def initialize(exp, e_base)
    raise "exp (#{exp}) cannot be <= 0" if exp <= 0.0
    raise "e_base (#{e_base}) cannot be < 0" if e_base < 0
    @exp = exp
    @e_base = e_base
  end

  # Returns energy for given size
  def energy(size)
    raise "size (#{size}) cannot be < 0" if size < 0.0
    return 0.0 if size == 0.0
    @e_base * (size ** @exp)
  end

  # Returns size for given energy
  def size(energy)
    raise "energy (#{energy}) cannot be < 0" if energy < 0.0
    return 0.0 if energy == 0.0
    (energy / @e_base) ** (1.0 / @exp)
  end
end