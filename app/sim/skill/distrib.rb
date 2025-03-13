require 'rubystats'

module Skill
  class Distrib
    # Returns random value within the distribution
    def rnd
      raise "Invalid call to base class function"
    end

    # Returns a random mutation of the specified value within the distribution
    def mutate(v)
      raise "Invalid call to base class function"
    end

    # Unmarshals from a hash and returns a new Distrib object of the correct type
    def self.unmarshal(h)
      class_from_name(h[:class]).unmarshal(h)
    end
  end

  # Represents linear distribution between two values (inclusive)
  class DistribLinear < Distrib
    attr_accessor :min, :max
    
    def initialize(min, max)
      @min = min
      @max = max
    end

    def rnd
      Random.rand(@min..@max)
    end

    def mutate(v)
      # since all values are equally likely we just return another random 
      # numnber
      rnd
    end

    # Marshals this object into a hash
    def marshal
      {
        class: self.class.to_s,
        min: @min,
        max: @max
      }
    end

    def self.unmarshal(h)
      DistribLinear.new(h[:min], h[:max])
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
    attr_accessor :mean, :stddev

    def initialize(mean, stddev)
      @mean = mean
      @stddev = stddev
    end

    def rnd
      Rubystats::NormalDistribution.new(@mean, @stddev).rng
    end

    def mutate(v)
      # we use the same stddev but center the distribution on the specified
      # value
      Rubystats::NormalDistribution.new(v, @stddev).rng
    end

    # Marshals this object into a hash
    def marshal
      {
        class: self.class.to_s,
        mean: @mean,
        stddev: @stddev
      }
    end

    def self.unmarshal(h)
      DistribNormal.new(h[:mean], h[:stddev])
    end
  end
end