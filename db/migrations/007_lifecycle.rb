Sequel.migration do
  up do
    alter_table :lifeforms do
      add_column :created_step, Integer
      add_column :died_step, Integer
      add_column :initial_size, Float
    end
    run "update lifeforms set created_step = 0;"
    run "alter table lifeforms alter column created_step set not null;"

    run "update lifeforms set initial_size = 0.0;"
    run "alter table lifeforms alter column initial_size set not null;"
  end

  down do
    alter_table :lifeforms do
      drop_column :created_step
      drop_column :died_step
      drop_column :initial_size
    end    
  end
end