require_relative './config/environment'

# Write all the output to stderr
Log.routers << Scribe::Router.new(Scribe::Level::INFO, Scribe::Formatter.new, Scribe::Outputter::Stderr.new)

######################################################################
# Helper functions
#######################################################################
def runcmd(cmd)      
    Log.debug(cmd)
    system(cmd)
end

######################################################################
# General targets
#######################################################################
desc "Starts Pry debugging console"
task :console do
    Pry.start
end

######################################################################
# sim - managing simulation environments
#######################################################################
namespace "sim" do
    desc "Creates a simulation with n lifeforms"
    task :create, [:n] do |t, args|
        num_lf = args[:n].to_i
        DB.transaction do
            env = EnvironmentFactory.new.gen.save

            [Zoo::Plant, Zoo::Grazer].each do |fact_class|
                pf = fact_class.new(env)
                (0...num_lf).each do
                    pf.gen.save
                end
            end
            Log.info("Created simulation: #{env.to_s}")
        end
    end

    desc "Lists all existing simulations"
    task :list do
        Log.info("Available simulation environments:")
        Environment.order(:created_at).reverse.each do |env|
            Log.info("  * #{env.to_s}")
        end
    end

    desc "Runs a simulation for the specified number of generations"
    task :run, [:id, :n] do |t, args|
        id = args[:id]
        num_gen = args[:n]
        env = Environment.where(id: id).first
        abort("Unable to find environment '#{id}'") if env.nil?
        Log.info("Running #{num_gen} generations of simulation #{id}...")
    
        env.log_self(Scribe::Level::INFO)
        (0...num_gen.to_i).each do
            env.run_step
            env.log_stats(Scribe::Level::INFO)    
        end
        env.log_self(Scribe::Level::INFO)
    end

    desc "Views details for a single simulation"
    task :view, [:id] do |t, args|
        id = args[:id]
        env = Environment.where(id: id).first
        abort("Unable to find environment '#{id}'") if env.nil?
        env.log_self(Scribe::Level::INFO)
        env.log_lifeforms(Scribe::Level::INFO)
        env.log_stats(Scribe::Level::INFO)
    end

    desc "Deletes a single simulation"
    task :delete, [:id] do |t, args|
        id = args[:id]
        DB.transaction do
            Log.info("Removing data associated with simulation #{id}...")
            [Lifeform].each do |klass|
                n = klass.where(environment_id: id).delete
                Log.info("Deleted #{n} rows from #{klass.to_s}")
            end
            Environment.where(id: id).delete
            Log.info("Deleted simuilation #{id}")
        end
    end

    desc "Deletes all existing simulations from the database"
    task :deleteall do
        DB.transaction do
            Log.info("Removing existing data...")
            [EnvStat, Lifeform, Environment, Species].each do |klass|
                n = klass.where(true).delete
                Log.info("Deleted #{n} rows from #{klass.to_s}")
            end
        end
    end
end

######################################################################
# db - for managing database schema
#######################################################################
namespace "db" do
    def schema_ver
        r = DB["select version from schema_info"].first
        abort "Unable to read schema_info" if r.nil?
        r[:version].to_i
    end

    def mig_dir
        DBDIR + "/migrations"
    end

    def db_cfg
        CFGDIR + "/database.yml"
    end

    def migrate_to(ver)
        runcmd("sequel -m #{mig_dir} -M #{ver} #{db_cfg}")
    end

    desc "Prints current schema version"
    task :ver do
        Log.info("Current schema version: #{schema_ver}")
    end

    desc "Migrates schema down one version"
    task :down do
        ver = schema_ver
        last_ver = ver - 1
        Log.info("Migrating down from #{ver} to #{last_ver}")
        migrate_to(last_ver)
    end

    desc "Migrates schema up one version"
    task :up do
        ver = schema_ver
        next_ver = ver + 1
        Log.info("Migrating up from #{ver} to #{next_ver}")
        migrate_to(next_ver)
    end

    desc "Runs all migrations starting at current schema version"
    task :all do
        ver = schema_ver
        Log.info("Migrating up from starting version: #{ver}")
        runcmd("sequel -m #{mig_dir} #{db_cfg}")
        Log.info("Ending schema version: #{schema_ver}")
    end

    # NOTE: There's an issue that if you do a schema reset then you won't be
    # able to subsequently run migrations up. This is because the schema reset
    # will delete database tables (e.g. environment) that are relied upon by
    # the Sequel ORM classes (e.g. Environment) and the lib/model/ files will
    # cause an error when loading. We can't trivially exclude these files
    # because they are needed for the sim namespace above. Future work could
    # be to split the Rakefile or look at how to dynamically load the models
    # when needed.
    desc "Resets schema to version 0; run with argument [y] if you want to skip confirmation prompt"
    task :reset, [:confirm] do |t, args|
        c = args[:confirm]
        if c == 'y'
            Log.info("Resetting to schema version 0")
            migrate_to(0)
        else
            Log.info("*** WARNING *** Resets your database to original state (schema 0)")
            Log.info("If you really want to do this rerun this target with argument [y]")
        end
    end
end