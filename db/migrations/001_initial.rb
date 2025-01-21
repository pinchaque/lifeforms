
Sequel.migration do
  up do
    tbl = 'environments'
    run <<-SQL
      create table #{tbl} (
        id uuid default uuid_generate_v4() primary key,
        width double precision not null,
        height double precision not null,
        time_step integer not null
      );
    SQL

    tbl = 'species'
    run <<-SQL
      create table #{tbl} (
        id uuid default uuid_generate_v4() primary key,
        name text not null,
        class_name text not null
      );
    SQL

    tbl = 'lifeforms'
    run <<-SQL
      create table #{tbl} (
        id uuid default uuid_generate_v4() primary key,
        environment_id uuid not null references environments(id),
        species_id uuid not null references species(id),
        parent_id uuid references lifeforms(id),
        energy double precision not null,
        size double precision not null,
        name text not null,
        obj_data text not null
      );
    SQL

    alter_table tbl do
      add_index :environment_id
      add_index :parent_id
      add_index :species_id
    end


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

  end

  down do
    drop_table :lifeform_locs
    drop_table :lifeforms
    drop_table :species
    drop_table :environments
  end
end