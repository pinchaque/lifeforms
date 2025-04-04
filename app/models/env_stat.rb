class EnvStat  < Sequel::Model
  plugin :timestamps, :force => true, :update_on_create => true


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