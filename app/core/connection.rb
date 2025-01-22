require 'sequel'
require 'yaml'

def db_conn
    Sequel.connect(YAML.load_file("#{DBDIR}/database.yml"))
end

DB = db_conn()