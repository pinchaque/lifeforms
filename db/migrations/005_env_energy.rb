Sequel.migration do
  change do
    alter_table :environments do
      add_column :energy_rate, Float, null: false, default: 0.0
    end
  end
end