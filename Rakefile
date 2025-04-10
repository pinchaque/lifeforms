require_relative './config/env_core'

# Write all the output to stderr
Log.routers << Scribe::Router.new(Scribe::Level::DEBUG, Scribe::Formatter.new, Scribe::Outputter::Stderr.new)

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
    def load_env_app
        require_relative './config/env_app'
    end

    def get_env(id)
        env = nil
        if id.nil?
            env = Environment.reverse(:created_at).first
            Log.fatal("Unable to find any simulation") if env.nil?
            Log.info("Using latest simulation #{env}")
        else
            env = Environment.where(id: id).first
            Log.fatal("Unable to find simulation '#{id}'") if env.nil?
        end
        return env
    end

    desc "Creates a simulation"
    task :create do |t, args|
        load_env_app
        DB.transaction do
            env = EnvironmentFactory.new.gen
            Log.info("Created simulation: #{env.to_s}")
        end
    end

    desc "Lists all existing simulations"
    task :list do
        load_env_app
        Log.info("Available simulation environments:")
        Environment.order(:created_at).reverse.each do |env|
            Log.info("  * #{env.to_s}")
        end
    end

    desc "Runs a simulation for the specified number of generations (default 1)"
    task :run, [:id, :n] do |t, args|
        load_env_app
        id = args[:id]
        num_gen = args[:n] || 1
        env = get_env(id)
        Log.info("Running #{num_gen} generations of simulation #{env.name}...")
    
        env.log_self(Scribe::Level::INFO)
        (0...num_gen.to_i).each do
            env.run_step
            env.log_stats(Scribe::Level::INFO)    
        end
        env.log_self(Scribe::Level::INFO)
    end

    desc "Views details for a single simulation"
    task :view, [:id] do |t, args|
        load_env_app
        id = args[:id]
        env = get_env(id)
        abort("Unable to find environment '#{id}'") if env.nil?
        env.log_self(Scribe::Level::INFO)
        env.log_spawners(Scribe::Level::INFO)
        env.log_lifeforms(Scribe::Level::INFO)
        env.log_stats(Scribe::Level::INFO)
    end

    desc "Deletes a single simulation"
    task :delete, [:id] do |t, args|
        load_env_app
        id = args[:id]
        Log.fatal("No id specified") if id.nil?
        DB.transaction do
            Log.info("Removing data associated with simulation #{id}...")
            [EnvStat, Spawner, Lifeform].each do |klass|
                n = klass.where(environment_id: id).delete
                Log.info("Deleted #{n} rows from #{klass.to_s}")
            end
            Environment.where(id: id).delete
            Log.info("Deleted simuilation #{id}")
        end
    end

    desc "Deletes all existing simulations from the database"
    task :deleteall do
        load_env_app
        DB.transaction do
            Log.info("Removing existing data...")
            [EnvStat, Spawner, Lifeform, Environment].each do |klass|
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