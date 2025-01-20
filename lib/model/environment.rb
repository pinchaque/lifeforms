class Environment  < Sequel::Model

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

  def add_lifeform_dist(parent, child, dist)
    parent_loc = @lifeform_locs[parent.id]
    @lifeforms[child.id] = child
    @lifeform_locs[child.id] = Location.at_dist(@width, @height, parent_loc, dist)
  end

  def run_step
    @lifeforms.values.shuffle.each do |l|
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

  def lifeforms_sorted
    @lifeforms.values.sort{ |a, b| a.name <=> b.name }
  end

  def to_s
    str = "[t=#{@time} | n=#{@lifeforms.count} | s=(#{@width}, #{@height})]\n"
    str += lifeforms_sorted.map{ |l| "  * #{lifeform_str(l)}" }.join("\n")
  end
end