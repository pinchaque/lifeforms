class EnvStat  < Sequel::Model
  plugin :timestamps, :force => true, :update_on_create => true

  # Returns the Species associated with this EnvStat
  def species
    Species.where(id: self.species_id).first
  end

  # Returns the total number of Lifeforms (living + dead)
  def count_lifeforms
    self.count_dead + self.count_living
  end

  # Returns the ratio of Lifeforms that are alive
  def perc_alive
    (self.count_lifeforms == 0) ? 0.0 : self.count_living.to_f / self.count_lifeforms
  end

  # Returns the ratio of Lifeforms that are dead
  def perc_dead
    1.0 - self.perc_alive
  end

  # Formats this EnvStat as a string for user display
  def to_s
    sprintf("[TS:%d] [%s] Alive: %d (+%d -%d) | Egy: %.1f | Age: %.1f | Dead: %d (%.1f%%)",
      self.time_step,
      self.species.name,
      self.count_living,
      self.count_born,
      self.count_died,
      self.sum_energy.nil? ? 0.0 : self.sum_energy,
      self.avg_age_living.nil? ? 0.0 : self.avg_age_living,
      self.count_dead,
      self.perc_dead * 100.0
      )
  end

  # Takes a snapshot of the current stats in the specified environment and 
  # stores them into env_stats. Will remove existing stats for the current
  # env+time_step to avoid duplicates.
  def self.snapshot_from_env(env)
    sql_clear = <<-SQL
      delete from env_stats where environment_id = ? and time_step = ?;
    SQL

    sql_populate = <<-SQL
      insert into env_stats (
        environment_id,
        time_step,
        species_id,
        count_living,
        count_dead,
        count_born,
        count_died,
        sum_energy,
        max_generation,
        avg_age, 
        avg_age_living)

        select 
          e.id as environment_id,
          e.time_step,
          lf.species_id,
          count(case when lf.died_step is null then lf.id else null end) as count_living,
          count(case when lf.died_step is null then null else lf.id end) as count_dead,
          count(case when lf.created_step = e.time_step then lf.id else null end) as count_born,
          count(case when lf.died_step = e.time_step then lf.id else null end) as count_died,
          sum(case when lf.died_step is null then lf.energy else 0.0 end) as sum_energy,
          max(lf.generation) as max_generation,
          avg((coalesce(lf.died_step, e.time_step) - lf.created_step)::float) as avg_age, 
          avg(case when lf.died_step is null then (e.time_step - lf.created_step)::float else null end) as avg_age_living
        from environments e
        inner join lifeforms lf on lf.environment_id = e.id
        where e.id = ?
        group by e.id, e.time_step, lf.species_id
        ;
      SQL

    DB.transaction do
      DB[sql_clear, env.id, env.time_step].first
      DB[sql_populate, env.id].first
    end
  end
end