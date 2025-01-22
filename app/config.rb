LIBDIR = File.expand_path('../app', File.dirname(__FILE__))
TMPDIR = File.expand_path('../tmp', File.dirname(__FILE__))
DBDIR = File.expand_path('../db', File.dirname(__FILE__))

Dir["#{LIBDIR}/core/*.rb"].each {|file| require file }
Dir["#{LIBDIR}/models/*.rb"].each {|file| require file }
Dir["#{LIBDIR}/zoo/*.rb"].each {|file| require file }
Dir["#{LIBDIR}/sim/*.rb"].each {|file| require file }


# require 'bundler'
# Bundler.require
# ActiveRecord::Base.establish_connection(
#   :adapter => 'sqlite3',
#   :database => 'db/development.sqlite'
# )
# require_all 'app'
