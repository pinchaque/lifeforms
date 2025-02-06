# A Plant is a lifeform that derives energy from the enviroment as opposed
# to other lifeforms.
class Plant < Lifeform
  MIN_SIZE = 1.0

  # Percentage of the environmental energy availale to this lifeform that it
  # actually absorbs
  attr_accessor :energy_absorb_perc

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

  # Returns the Environment of which this lifeform is a part
  def env
    Environment.where(id: environment_id).first  
  end
  
  # Returns area of the plan assuming circle of diameter "size"
  def area
    Math::PI * ((size / 2.0) ** 2.0)
  end
  
  def marshal_to_h
    super.merge({
      energy_absorb_perc: energy_absorb_perc,
      energy_metabolic_rate: energy_metabolic_rate,
      energy_size_ratio: energy_size_ratio,
      growth_invest_perc: growth_invest_perc,
      repro_threshold: repro_threshold,
      repro_num_offspring: repro_num_offspring,
      repro_energy_inherit_perc: repro_energy_inherit_perc
    })
  end

  def marshal_from_h(h)
    @energy_absorb_perc = h[:energy_absorb_perc]
    @energy_metabolic_rate = h[:energy_metabolic_rate]
    @energy_size_ratio = h[:energy_size_ratio]
    @growth_invest_perc = h[:growth_invest_perc]
    @repro_threshold = h[:repro_threshold]
    @repro_num_offspring = h[:repro_num_offspring]
    @repro_energy_inherit_perc = h[:repro_energy_inherit_perc]
    super(h)
  end

  # The gross amount of energy supplied to this lifeform based on its area
  # alone, not taking into account overlaps with other lifeforms.
  def env_energy_gross
    env.energy_rate * area
  end

  # The amount of energy lost due to overlaps with other organisms. This is
  # returned as a non-negative number.
  def energy_overlap_loss
    0.0
  end

  # Returns the max amount of environmental energy available to this lifeform
  # on this step. This is calculated by taking the env.energy_rate and then
  # reducing it based on overlaps between this and other Plants.
  def env_energy
    env_energy_gross - energy_overlap_loss
  end

  # Returns the total metabolic energy needed for a timestep based on the 
  # current lifeform size.
  def metabolic_energy
    area() * self.energy_metabolic_rate
  end

  # Resizes this lifeform up or down based on the specified energy delta and
  # using the energy_size_ratio. Specifying a positive energy means we are 
  # growing by using up that amount. Negative means shrinking and gaining
  # that amount. This will update both self.size and self.energy after the 
  # resize.
  def resize_for_energy(egy)
    if egy > self.energy
      # cannot use more energy than we have
      raise sprintf("resize_for_energy(%f) failed because lifeform only has energy %f", egy, self.energy) 
    end

    # size delta is computed using the energy_size_ratio
    delta = egy / self.energy_size_ratio

    if self.size + delta < 0.0
      # cannot shrink below ero
      raise sprintf("resize_for_energy(%f) failed because size (%f) + delta (%f) < 0.0", egy, self.size, delta)
    end

    self.size += delta
    self.energy -= egy
  end

  # At each time step the Plant first absorbs energy from the environment
  # based on its area and energy_absorb_perc. Note that if this plant overlaps
  # other plants then that reduces the new energy available on this turn.
  # 
  # Then we subtract 
  def run_step
    super

    # Calc out how much energy we can absorb from the environment
    new_env_energy = env_energy() * perc(self.energy_absorb_perc)

    # Subtract off our basal metabolic rate to get the energy delta for this
    # time step
    delta_energy = new_env_energy - metabolic_energy()

    # If we have an energy surplus then we are in growth mode
    if delta_energy > 0.0
      # first figure out how much of this surplus energy we are investing
      # in growth
      growth_energy = delta_energy * perc(growth_invest_perc)
      resize_for_energy(growth_energy)

      raise("THIS IS WRONG because resize_for_energy is also deducting energy")

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