Sequel.migration do
  change do
    alter_table :lifeforms do
      add_column :generation, Integer, default: 0, null: false
    end
  end
end