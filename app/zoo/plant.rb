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

  # Returns radius of the circle for this lifeform
  def radius
    self.size / 2.0
  end
  
  # Returns area of the lifeform assuming circle of diameter "size"
  def area
    Math::PI * (radius ** 2.0)
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
    # To calculate the loss we add up the areas of all the overlapping 
    # lifeforms of this species. Then we divide that by two because 
    # the lifeforms are splitting the energy. Then we multiply by the
    # environmental energy rate to get actual energy.
    # 
    # NOTE: This does not take into account the case where there are more than
    # 2 lifeforms overlapping and splitting the same area. The actual loss 
    # would be less if we calculated that precisely. So this is an heuristic
    # that will over-estimate the energy loss.
    env.energy_rate * 0.5 * find_overlaps.map{ |lf| 
      circle_area_intersect(x, y, radius, lf.x, lf.y, lf.radius) }.sum
  end

  # Returns the max amount of environmental energy available to this lifeform
  # on this step. This is calculated by taking the env.energy_rate and then
  # reducing it based on overlaps between this and other Plants.
  def env_energy
    [0.0, env_energy_gross - energy_overlap_loss].max
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
  # If the requested resize cannot be performed (due to size or energy 
  # limitations) then the function will do what it can, reducing size or
  # energy to 0.0 as appropriate. Then it will return false.  
  def resize_for_energy(egy)
    # growing
    if egy > 0.0
      if egy > self.energy
        # cannot use more energy than we have
        self.size += Math.sqrt(self.energy / self.energy_size_ratio)
        self.energy = 0.0
        false
      else
        self.size += Math.sqrt(egy / self.energy_size_ratio)
        self.energy -= egy
        true
      end
    # shrinking
    elsif egy < 0.0
      delta_size = -1.0 * Math.sqrt(-1.0 * egy / self.energy_size_ratio)
      if self.size + delta_size < 0.0
        # cannot shrink more than our size
        self.energy += self.size * self.size * self.energy_size_ratio
        self.size = 0.0
        false
      else
        self.size += delta_size
        self.energy -= egy
        true
      end
    # no-op
    else
      true
    end
  end

  # Runs a time step for this lifeform. Figures out environmental energy, 
  # subtracta metabolic energy rate, then splits the energy between growth
  # and storage. If enough energy is stored, then it reproduces.
  def run_step
    super

    logf("[%s] run_step start", to_s)

    # Calc out how much energy we can absorb from the environment
    new_env_energy = env_energy() * perc(self.energy_absorb_perc)

    # Subtract off our basal metabolic rate to get the energy delta for this
    # time step
    meta = metabolic_energy()
    delta_energy = new_env_energy - meta
    
    logf("env_energy:%f - metabolic:%f = delta:%f", new_env_energy, meta, delta_energy)


    # If we have an energy surplus then we are in growth mode
    if delta_energy > 0.0
      # add to our energy stores
      self.energy += delta_energy

      # invest some of this surplus into growth
      growth_energy = delta_energy * perc(growth_invest_perc)
      resize_for_energy(growth_energy)
      logf("Growing with growth_energy:%f; new size:%f energy:%f", growth_energy, size, energy)

      # now check if we have enough energy to reproduce
      if self.energy >= repro_threshold
        logf("Reproducing since energy:%f > repro_thresh:%f", self.energy, repro_threshold)
        reproduce
      end
    # Else if we have an energy deficit then we are in reduce mode
    elsif delta_energy < 0.0
      # Reduce current energy by this delta; this may push energy negative
      self.energy += delta_energy

      # If we've gone negative then we need to downsize the lifeform
      growth_energy = self.energy
      if growth_energy < 0.0
        resize_for_energy(growth_energy)
        logf("Shrinking with growth_energy:%f; new size:%f energy:%f", growth_energy, size, energy)

        if size < 0.0 || energy < 0.0
          # TODO: if the organism is too small then we kill it
          self.size = 0.0
          self.energy = 0.0
        end
      end
    end
    logf("[%s] run_step end", to_s)
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
    save

    logf("Creating %d children...", repro_num_offspring)

    r = Reproduce.new(self)
    r.generate(offspring_energy_each, repro_num_offspring) do |child|
      child.set_loc_dist(self.x, self.y, self.radius)
      child.save
      logf("  - %s", child.to_s)
    end
    logf("After reproducing energy:%f", energy)
  end

  # Returns the bounding box (square) around this lifeform
  def bounding_box
    r = self.radius
    return x - r, y - r, x + r, y + r
  end

  # Returns all other lifeforms in this environment that are potentially
  # overlapping with this one. We are guaranteed that there are no ovelraps
  # that aren't in the return value. However, some of the returned Lifeforms
  # might not be actual overlaps. This function uses heuristics within a 
  # DB query to get the list, which should then be compared in more detail.
  def find_potential_overlaps
    # we identify potential overlaps by seeing if the bounding boxes of the
    # lifeforms are overlapping
    x0, y0, x1, y1 = bounding_box
    ds = Plant.
      where(Sequel.lit('lifeforms.environment_id = ?', [environment_id])).
      where(Sequel.lit('lifeforms.species_id = ?', [species_id])).
      where(Sequel.lit('lifeforms.id != ?', [id])).
      where(Sequel.lit('lifeforms.x <= ? + (lifeforms.size / 2.0)', [x1])).
      where(Sequel.lit('lifeforms.x >= ? - (lifeforms.size / 2.0)', [x0])).
      where(Sequel.lit('lifeforms.y <= ? + (lifeforms.size / 2.0)', [y1])).
      where(Sequel.lit('lifeforms.y >= ? - (lifeforms.size / 2.0)', [y0]))
    ds.all
  end

  # Returns all other lifeforms in this environment that overlap this one.
  def find_overlaps
    find_potential_overlaps.select do |o|
      # we have a real overlap if the actual distance between the centers
      # is <= the sum of the radii of the two lifeforms
      dx = o.x - self.x
      dy = o.y - self.y
      dist = Math.sqrt(dx * dx + dy * dy)
      dist <= (self.size + o.size) / 2.0
    end
  end
end