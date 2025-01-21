class Plant < Lifeform

  # Rate at which energy grows in each step
  attr_accessor :growth_rate

  # Energy level at which the lifeform splits
  attr_accessor :energy_split

  def marshal_to_h
    h = super
    h[:growth_rate] = growth_rate
    h[:energy_split] = energy_split
    h
  end

  def marshal_from_h(h)
    @growth_rate = h[:growth_rate]
    @energy_split = h[:energy_split]
    super(h)
  end

  def copy_from(other)
    super
    @growth_rate = other.growth_rate
    @energy_split = other.energy_split
  end

  def run_step(env)
    super(env)
    if @energy > @energy_split
      logf("%s is reproducing (%.2f > %.2f)", to_s, @energy, @energy_split)
      reproduce.each do |child|
        env.add_lifeform_dist(self, child, size)
        logf("Added child %s", child.to_s)
      end
    else
      @energy *= (1.0 + @growth_rate)
    end
  end
end