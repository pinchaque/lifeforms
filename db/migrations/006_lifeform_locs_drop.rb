Sequel.migration do
  up do
    drop_table :lifeform_locs
    run "alter table lifeforms add column x double precision;"
    run "alter table lifeforms add column y double precision;"
    run "create index lifeforms_x_idx on lifeforms(x);"
    run "create index lifeforms_y_idx on lifeforms(y);"
    run "update lifeforms set x = 0.0, y = 0.0;"
    run "alter table lifeforms alter column x set not null;"
    run "alter table lifeforms alter column y set not null;"
  end

  down do
    tbl = 'lifeform_locs'
    run <<-SQL
      create table #{tbl} (
        id uuid default uuid_generate_v4() primary key,
        environment_id uuid not null references environments(id),
        lifeform_id uuid not null references lifeforms(id),
        x double precision not null,
        y double precision not null
      );
    SQL

    run "create unique index lifeform_locs_uniq_idx on lifeform_locs(environment_id, lifeform_id);"
    run "alter table lifeforms drop column x;"
    run "alter table lifeforms drop column y;"
  end
end