class Environment  < Sequel::Model
  plugin :timestamps, :force => true, :update_on_create => true

  #####################################################################
  # Sequel ORM hooks
  #####################################################################

  def before_validation
    self.time_step = 0 if self.time_step.nil?
    set_random_name if self.name.nil?
    super
  end

  #####################################################################
  # Helper methods to get related objects
  #####################################################################

  # Returns all lifeforms in this environment.
  def lifeforms
    lifeforms_ds.all
  end
  
  # Returns Sequel Dataset for all living lifeforms in this environment.
  def lifeforms_ds
    Lifeform.where(environment_id: id, died_step: nil)
  end

  # Returns all stats for this environment for the specified time step, or 
  # the current time_step if nil.
  def stats(ts = nil)
    ts = self.time_step if ts.nil?
    EnvStat.where(environment_id: self.id, time_step: ts).all
  end

  #####################################################################
  # Simulation-related methods
  #####################################################################

  def run_steps(n)
    (0...n).each { |i| run_step }
  end

  def run_step
    DB.transaction do
      self.time_step += 1
      save
      lifeforms_ds.all.shuffle.each do |l|
        l.run_step.save
      end
      EnvStat.snapshot_from_env(self)
    end
  end

  def set_random_name
    self.name = (NameParts::ENV_ADJ.sample.capitalize + " " + NameParts::ENV_TYPE.sample.capitalize).strip
  end

  #####################################################################
  # Frontend interaction data
  #####################################################################

  def render_data
    lifeforms.map { |l| l.render_data }
  end

  #####################################################################
  # Logging & Debugging
  #####################################################################

  def to_s_detailed
    to_s + "\n" + lifeforms_ds.order(:name).map{ |l| "  * #{l.to_s}" }.join("\n")
  end

  def to_s
    sprintf("id:%s name:%s created:%s timestep:%d lifeforms:%d size:(%d,%d)",
      id, name, created_at, time_step, lifeforms.count, width, height)
  end

  def log_self(level = Scribe::Level::TRACE)
    log(level, 'Environment', id: self.id, ts: self.time_step, 
      egy_rate: self.energy_rate, width: self.width, height: self.height)
  end

  def log_stats(level = Scribe::Level::TRACE)
    stats.each do |s|
      log(level, s.to_s)
    end
  end

  def log_lifeforms(level = Scribe::Level::TRACE)
    lifeforms.each do |lf|
      log(level, "  * #{lf.to_s}")
    end
  end

  # outputs trace log message with this lifeform and additional context
  def log(level, msg, **ctx)
    Log.log(level, msg, env: self, **ctx)
  end
  
  # outputs trace log message with this lifeform and additional context
  def log_trace(msg, **ctx)
    log(Scribe::Level::TRACE, msg, **ctx)
  end

end