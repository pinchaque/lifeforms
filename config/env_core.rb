require 'bundler'
Bundler.require

APPDIR = File.expand_path('../app', File.dirname(__FILE__))
TMPDIR = File.expand_path('../tmp', File.dirname(__FILE__))
DBDIR = File.expand_path('../db', File.dirname(__FILE__))
CFGDIR = File.expand_path('../config', File.dirname(__FILE__))
LOGDIR = File.expand_path('../log', File.dirname(__FILE__))

def db_conn
  Sequel.connect(YAML.load_file("#{CFGDIR}/database.yml"))
end

DB = db_conn()

Dir["#{APPDIR}/core/**/*.rb"].each {|file| require file }
LogFmt = Scribe::Formatter.new
Log = Scribe::Logger.new(
  Scribe::Router.new(
    Scribe::Level::TRACE, 
    LogFmt,
    Scribe::Outputter::File.new(LOGDIR, "app")))