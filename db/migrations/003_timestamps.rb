Sequel.migration do
  tables = %w{environments lifeform_locs lifeforms species}
  cols = %w{created_at updated_at}
  up do
    tables.each do |table|
      cols.each do |col|
        run "alter table #{table} add column #{col} timestamp with time zone not null;"
      end
    end
  end

  down do
    tables.each do |table|
      cols.each do |col|
        run "alter table #{table} drop column #{col};"
      end
    end
  end
end