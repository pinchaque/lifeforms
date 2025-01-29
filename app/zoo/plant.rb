class Plant < Lifeform

  # Rate at which energy grows in each step
  attr_accessor :growth_rate

  # Energy level at which the lifeform splits
  attr_accessor :energy_split

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

  def run_step
    super
    if energy > @energy_split
      logf("%s is reproducing (%.2f > %.2f)", to_s, energy, @energy_split) if debug

      r = Reproduce.new(self)
      r.generate(1) do |child|
        env.add_lifeform_dist(self, child, size)
        logf("Added child %s", child.to_s) if debug
      end
    else
      self.energy *= (1.0 + @growth_rate)
    end
    self
  end
end