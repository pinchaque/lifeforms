# A Plant is a lifeform that derives energy from the enviroment as opposed
# to other lifeforms.
class Plant < Lifeform
  MIN_SIZE = 1.0
  EXP = 3.0

  # Percentage of the environmental energy available to this lifeform that it
  # actually absorbs
  attr_accessor :energy_absorb_perc

  # Amount of energy the lifeform takes at size 1; this is used to determine
  # the metabolic energy usage as the lifeform grows and shrinks
  attr_accessor :energy_base

  # Target percentage of the incoming energy that this lifeform tries to 
  # move into its energy stores. It will grow or shrink to try to achieve
  # this percentage
  attr_accessor :energy_reserve_perc

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
  
  def marshal
    super.merge({
      energy_absorb_perc: energy_absorb_perc,
      energy_base: energy_base,
      energy_reserve_perc: energy_reserve_perc,
      repro_threshold: repro_threshold,
      repro_num_offspring: repro_num_offspring,
      repro_energy_inherit_perc: repro_energy_inherit_perc
    })
  end

  def unmarshal(h)
    @energy_absorb_perc = h[:energy_absorb_perc]
    @energy_base = h[:energy_base]
    @energy_reserve_perc = h[:energy_reserve_perc]
    @repro_threshold = h[:repro_threshold]
    @repro_num_offspring = h[:repro_num_offspring]
    @repro_energy_inherit_perc = h[:repro_energy_inherit_perc]
    super(h)
  end

  def energy_fn
    EnergyFn.new(Plant::EXP, self.energy_base)
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
    energy_fn.energy(self.size)
  end

  # Runs a time step for this lifeform. Figures out environmental energy, 
  # subtracta metabolic energy rate, then splits the energy between growth
  # and storage. If enough energy is stored, then it reproduces.
  def run_step
    super

    Log.trace(sprintf("[%s] run_step start", to_s))

    # Calc out how much energy we can absorb from the environment
    e_env = env_energy() * perc(self.energy_absorb_perc)

    # Subtract off our basal metabolic rate to get the energy delta for this
    # time step
    e_meta = metabolic_energy()

    # calculate the target amount of energy to reserve
    e_reserve = e_env * perc(self.energy_reserve_perc)

    # and the target metabolic energy usage
    e_meta_target = e_env - e_reserve
    
    Log.trace(sprintf("e_env:%f e_meta:%f e_reserve:%f e_meta_target:%f", e_env, e_meta, e_reserve, e_meta_target))

    # update our current energy level
    self.energy = [0.0, self.energy + e_env - e_meta].max

    # SURVIVAL MODE - we aren't generating enough energy to sustain ourselves
    if e_env < e_meta
      
      # downsize
      self.size /= 2.0
      self.energy = 0.1 # so we don't kill it right away

      Log.trace(sprintf("SURVIVAL: energy:%f size:%f", self.energy, self.size))
    else
      # we are self-sustaining but might be not sized right (too big or too 
      # small). so let's figure out what that size should be and get halfway 
      # there
      size_target = energy_fn.size(e_meta_target)
      size_new = (self.size + size_target) / 2.0
      Log.trace(sprintf("SUSTAINING: energy:%f size_old:%f size_target:%f size_new:%f", 
        self.energy, self.size, size_target, size_new))
      self.size = size_new

      # now check if we have enough energy to reproduce
      if self.energy >= repro_threshold
        Log.trace(sprintf("Reproducing since energy:%f > repro_thresh:%f", self.energy, repro_threshold))
        reproduce
      end      
    end
    
    # kill the lifeform off if needed
    cull
    Log.trace(sprintf("KILLED: energy:%f size:%f", self.energy, self.size)) if is_dead?
    Log.trace("[#{to_s}] run_step end")
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

    Log.trace("Creating #{repro_num_offspring} children...")

    r = Reproduce.new(self)
    r.generate(offspring_energy_each, repro_num_offspring) do |child|
      child.set_loc_dist(self.x, self.y, self.radius)
      child.save
      Log.trace("  - #{child.to_s}")
    end
    Log.trace(sprintf("After reproducing energy:%f", energy))
    self
  end

  # Marks this organism as dead if it is too small or out of energy
  def cull
    mark_dead if self.size < MIN_SIZE || self.energy <= 0.0
    self
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