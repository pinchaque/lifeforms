Sequel.migration do
  up do
    alter_table :lifeforms do
      drop_column :class_name
      add_column :energy_base, Float, null: false
      add_column :energy_exp, Float, null: false
    end
  end

  down do
    run "alter table lifeforms add column class_name text not null"
    alter_table :lifeforms do
      drop_column :energy_base
      drop_column :energy_exp
    end
  end
end