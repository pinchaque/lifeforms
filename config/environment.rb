require 'bundler'
Bundler.require

APPDIR = File.expand_path('../app', File.dirname(__FILE__))
TMPDIR = File.expand_path('../tmp', File.dirname(__FILE__))
DBDIR = File.expand_path('../db', File.dirname(__FILE__))
CFGDIR = File.expand_path('../config', File.dirname(__FILE__))

def db_conn
    Sequel.connect(YAML.load_file("#{CFGDIR}/database.yml"))
end

DB = db_conn()

Dir["#{APPDIR}/core/*.rb"].each {|file| require file }
Dir["#{APPDIR}/models/*.rb"].each {|file| require file }
Dir["#{APPDIR}/zoo/*.rb"].each {|file| require file }
Dir["#{APPDIR}/sim/*.rb"].each {|file| require file }
Dir["#{APPDIR}/controllers/*.rb"].each {|file| require file }
