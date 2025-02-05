# A Plant is a lifeform that derives energy from the enviroment as opposed
# to other lifeforms.
class Plant < Lifeform
  MIN_SIZE = 1.0

  # Rate at which this lifeform absorbs the environmental energy that is
  # available to it.
  attr_accessor :energy_absorb_rate

  # Energy usage per time step per unit area (aka basal metabolic rate)
  attr_accessor :energy_metabolic_rate

  # Amount of energy it takes to grow/shrink by a unit of size. This is used
  # both for growth as well as size reduction.
  attr_accessor :energy_size_ratio

  # Percentage of its positive energy balance the lifeform invests into size 
  # growth as opposed to increasing energy reserves.
  attr_accessor :growth_invest_perc

  # Energy level at which the lifeform reproduces
  attr_accessor :repro_threshold

  # How many offspring the lifeform creates upon reproduction
  attr_accessor :repro_num_offspring

  # What percentage of this lifeform's energy reserves it gives to its 
  # offspring upon reproduction.
  attr_accessor :repro_energy_inherit_perc

  # Returns area of the plan assuming circle of diameter "size"
  def area
    Math::PI * ((size / 2.0) ^ 2.0)
  end
  
  def marshal_to_h
    super.merge({
      growth_rate: growth_rate,
      energy_split: energy_split
    })
  end

  def marshal_from_h(h)
    @growth_rate = h[:growth_rate]
    @energy_split = h[:energy_split]
    super(h)
  end

  # Returns the max amount of environmental energy available to this lifeform
  # on this step. This is calculated by taking the env.energy_rate and then
  # reducing it based on overlaps between this and other Plants.
  def env_energy
    0.0
  end

  # Returns the total metabolic energy needed for a timestep based on the 
  # current lifeform size.
  def metabolic_energy
    area() * perc(self.energy_metabolic_rate)
  end

  # Resizes this lifeform up or down based on the specified energy delta and
  # using the energy_size_ratio. This will update both self.size and
  # self.energy after the resize.
  def resize_for_energy(egy)
    self.energy = 1.0
    self.size = 1.0
    # TODO implement this
  end

  # At each time step the Plant first absorbs energy from the environment
  # based on its area and energy_absorb_rate. Note that if this plant overlaps
  # other plants then that reduces the new energy available on this turn.
  # 
  # Then we subtract 
  def run_step
    super

    # Calc out how much energy we can absorb from the environment
    new_env_energy = env_energy() * self.energy_absorb_rate

    # Subtract off our basal metabolic rate to get the energy delta for this
    # time step
    delta_energy = new_env_energy - metabolic_energy()

    # If we have an energy surplus then we are in growth mode
    if delta_energy > 0.0
      # first figure out how much of this surplus energy we are investing
      # in growth
      growth_energy = delta_energy * perc(growth_invest_perc)
      resize_for_energy(growth_energy)

      # remainnig energy goes into our stores
      self.energy += (delta_energy - growth_energy)

      # now check if we have enough energy to reproduce
      reproduce if self.energy >= repro_threshold
    # Else if we have an energy deficit then we are in reduce mode
    elsif delta_energy < 0.0
      # Reduce current energy by this delta
      self.energy += delta_energy

      # If we've gone negative then we need to downsize the lifeform
      if self.energy < 0.0
        resize_for_energy(self.energy)

        # TODO: if the organism is too small then we kill it
      end
    end
    self
  end

  # Total amount of energy to give to offspring when reproducing. This is
  # calculated based on the current energy reserves multiplied by the 
  # percentage we give to offspring.
  def offspring_energy_tot
    perc(repro_energy_inherit_perc) * self.energy
  end

  # The amount of energy each offspring will get. This is simply the total
  # divided by the number of offspring
  def offspring_energy_each
    offspring_energy_tot / repro_num_offspring
  end

  # Create offspring of this lifeform
  def reproduce
    # Subtract the energy we're giving to the offspring
    self.energy -= offspring_energy_tot

    r = Reproduce.new(self)
    r.generate(offspring_energy_each, repro_num_offspring) do |child|
      env.add_lifeform_dist(self, child, size)
    end
  end
end