class Environment

  attr_reader :width, :height
  attr_reader :time

  def initialize(w, h)
    @width = w.to_f
    @height = h.to_f
    @lifeforms = Hash.new
    @lifeform_locs = Hash.new
    @time = 0
  end

  def add_lifeform_rnd(l)
    @lifeforms[l.id] = l
    @lifeform_locs[l.id] = Location.random(@width, @height)
  end

  def add_lifeform_dist(l, dist)
    Location.at_dist()

  end

  def run_step
    # TODO: randomize order
    @lifeforms.each do |l|
      l.run_step(self)
    end

    @time += 1
  end

  def lifeform_str(l)
    fmt = "%.2f"
    loc = @lifeform_locs[l.id]
    loc_str = sprintf(fmt, loc.x) + ", " + sprintf(fmt, loc.y)
    l.to_s + " [Loc: #{loc_str}]"
  end

  def to_s
    str = "[#{@lifeforms.count} Lifeforms | Size #{@width}x#{@height} | Time #{@time}]\n"
    str += @lifeforms.values.map{ |l| "  * #{lifeform_str(l)}" }.join("\n")
  end
end