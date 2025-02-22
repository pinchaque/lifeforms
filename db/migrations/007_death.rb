Sequel.migration do
  up do
    alter_table :lifeforms do
      add_column :created_step, Integer
      add_column :died_step, Integer
    end
    run "update lifeforms set created_step = 0;"
    run "alter table lifeforms alter column created_step set not null;"
  end

  down do
    alter_table :lifeforms do
      drop_column :created_step
      drop_column :died_step
    end    
  end
end