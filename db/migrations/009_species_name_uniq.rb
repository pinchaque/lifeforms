Sequel.migration do
  up do
    run "create unique index species_name_idx on species(name);"
  end

  down do
    run "drop index species_name_idx;"
  end
end