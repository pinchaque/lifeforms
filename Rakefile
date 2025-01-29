require_relative './config/environment'

desc "Starts Pry debugging console"
task :console do
    Pry.start
end

namespace "sim" do
    desc "Creates a simulation"
    task :create do
        DB.transaction do
            env = Environment.new(width: 100, height: 100).save
            pf = PlantFactory.new
            (0..5).each do
                env.add_lifeform_rnd(pf.gen)
            end
            log("Created simulation: #{env.to_s}")
        end
    end

    desc "Lists all existing simulations"
    task :list do
        log("Available simulation environments:")
        Environment.order(:created_at).reverse.each do |env|
            log("  * #{env.to_s}")
        end
    end

    desc "Runs a simulation for the specified number of generations"
    task :run, [:id, :n] do |t, args|
        id = args[:id]
        num_gen = args[:n]
        env = Environment.where(id: id).first
        abort("Unable to find environment '#{id}'") if env.nil?
        log("Running #{num_gen} generations of simulation #{id}...")
    
        (0..num_gen.to_i).each do
            env.run_step
            log(env.to_s)
        end
    end

    desc "Views details for a single simulation"
    task :view, [:id] do |t, args|
        id = args[:id]
        env = Environment.where(id: id).first
        abort("Unable to find environment '#{id}'") if env.nil?
        log(env.to_s_detailed)
    end

    desc "Deletes a single simulation"
    task :delete, [:id] do |t, args|
        id = args[:id]
        DB.transaction do
            log("Removing data associated with simulation #{id}...")
            [LifeformLoc, Lifeform].each do |klass|
                n = klass.where(environment_id: id).delete
                log("Deleted #{n} rows from #{klass.to_s}")
            end
            Environment.where(id: id).delete
            log("Deleted simuilation #{id}")
        end
    end

    desc "Deletes all existing simulations from the database"
    task :deleteall do
        DB.transaction do
            log("Removing existing data...")
            [LifeformLoc, Lifeform, Environment, Species].each do |klass|
                n = klass.where(true).delete
                log("Deleted #{n} rows from #{klass.to_s}")
            end
        end
    end
end