require_relative './config/environment'

desc "Starts Pry debugging console"
task :console do
    Pry.start
end

desc "Clears existing data from the database"
task :cleardata do
    DB.transaction do
        log("Removing existing data...")

        n = LifeformLoc.where(true).delete
        log("Deleted #{n} rows from lifeform_locs")

        n = Lifeform.where(true).delete
        log("Deleted #{n} rows from lifeforms")

        n = Environment.where(true).delete
        log("Deleted #{n} rows from environments")
    end
end


desc "Runs a basic simulation to populate the db with sampel data"
task runsim: [:cleardata] do
    log("Running Simulation...")
    env = Environment.new(width: 100, height: 100).save
    pf = PlantFactory.new
    (0..5).each do 
    env.add_lifeform_rnd(pf.gen)
    end

    puts(env.to_s)
    (0..10).each do
        env.run_step
        puts("-" * 72)
        puts(env.to_s)
    end
end