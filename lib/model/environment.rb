class Environment  < Sequel::Model
  def before_save
    time_step = 0 if time_step.nil?
    super
  end

  # Returns all lifeforms in this environment.
  def lifeforms
    Lifeforms.where(environment_id: @env.id)
  end

  def to_s
    str = "[t=#{time_step} | n=#{lifeforms.count} | s=(#{width}, #{height})]\n"
    str += lifeforms.order(:name).map{ |l| "  * #{l.to_s}" }.join("\n")
  end
end