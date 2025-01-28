require_relative './config/environment'

desc "Starts Pry debugging console"
task :console do
    Pry.start
end


namespace "sim" do
    desc "Creates a simulation"
    task :create do
        log("Creating simulation...")
        env = Environment.new(width: 100, height: 100).save
        pf = PlantFactory.new
        (0..5).each do 
        env.add_lifeform_rnd(pf.gen)
        end

        puts(env.to_s)
    end

    desc "Lists all existing simulations"
    task :list do
        log("Available simulation environments:")
        Environment.all.each do |env|
            puts("  * #{env.id}")
        end
    end

    desc "Runs a simulation for the specified number of generations"
    task :run, [:id, :n] do |t, args|
        id = args[:id]
        num_gen = args[:n]
        env = Environment.where(id: id).first
        abort("Unable to find environment '#{id}'") if env.nil?
        puts("Running #{num_gen} generations of simulation #{id}...")
    
        (0..num_gen.to_i).each do
            env.run_step
            puts("-" * 72)
        end
        puts(env.to_s)
    end

    desc "Deletes all existing simulations from the database"
    task :deleteall do
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
end