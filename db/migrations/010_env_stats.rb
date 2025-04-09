Sequel.migration do
  up do
    run <<-SQL
      create table env_stats (
        id uuid default uuid_generate_v4() primary key,
        environment_id uuid not null references environments(id),
        time_step integer not null,
        species_id uuid not null references species(id),
        created_at timestamp with time zone not null default now(),
        updated_at timestamp with time zone not null default now(),
        count_living integer not null,
        count_dead integer not null,
        count_born integer not null,
        count_died integer not null,
        sum_energy double precision not null,
        max_generation integer,
        avg_age double precision, 
        avg_age_living double precision
      );
    SQL

    run "create unique index env_stats_uniq_idx on env_stats(environment_id, time_step, species_id);"
  end

  down do
    drop_table :env_stats
  end
end