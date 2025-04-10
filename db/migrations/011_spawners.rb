Sequel.migration do
  up do
    run("insert into species (name) values ('Grazer'), ('Plant') on conflict do nothing;")
    run "alter table species add column class_name varchar;"
    run "update species set class_name = 'Zoo::' || name;"
    run "alter table species alter column class_name set not null;"

    run <<-SQL
      create table spawners (
        id uuid default uuid_generate_v4() primary key,
        environment_id uuid not null references environments(id),
        species_id uuid not null references species(id),
        created_at timestamp with time zone not null default now(),
        updated_at timestamp with time zone not null default now(),
        p_spawn double precision not null,
        min_lifeforms integer,
        max_lifeforms integer
      );
    SQL

    run "create unique index spawners_uniq_idx on spawners(environment_id, species_id);"
  end

  down do
    drop_table :spawners
    run "alter table species drop column class_name;"
  end
end