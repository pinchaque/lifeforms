Sequel.migration do
  change do
    alter_table :environments do
      add_column :name, String, null: false
    end
  end
end