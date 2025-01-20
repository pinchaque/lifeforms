class Environment  < Sequel::Model

  def initialize
    time_step = 0
    super
  end

  def lifeform_str(l)
    fmt = "%.2f"
    loc = @lifeform_locs[l.id]
    loc_str = sprintf(fmt, loc.x) + ", " + sprintf(fmt, loc.y)
    l.to_s + " [Loc: #{loc_str}]"
  end

  # Returns all lifeforms in this environment.
  def lifeforms
    Lifeforms.where(environment_id: @env.id)
  end

  def to_s
    str = "[t=#{time_step} | n=#{lifeforms.count} | s=(#{width}, #{height})]\n"
    str += lifeforms.order(:name).map{ |l| "  * #{lifeform_str(l)}" }.join("\n")
  end
end