require 'rubystats'

module Skill
  class Distrib
    # Returns random value within the distribution
    def rnd
      raise "Invalid call to base class function"
    end    
  end

  # Represents linear distribution between two values (inclusive)
  class DistribLinear < Distrib
    def initialize(min, max)
      @min = min
      @max = max
    end

    def rnd
      Random.rand(@min..@max)
    end
  end

  # Represents Normal distribution with specified mean and standard deviation
  # "Standard deviation is a measure of how spread out the values in a data set
  # are around the mean, while normal distribution is a probability 
  # distribution that is symmetric about the mean, forming a bell-shaped curve. 
  # In a normal distribution, about 68% of the data falls within one standard 
  # deviation of the mean, 95% within two standard deviations, and 99.7% within 
  # three standard deviations, known as the empirical rule."
  class DistribNormal < Distrib
    def initialize(mean, stddev)
      @mean = mean
      @stddev = stddev
      @dist = Rubystats::NormalDistribution.new(mean, stddev)
    end

    def rnd
      @dist.rng
    end
  end
end