Dir["#{APPDIR}/models/*.rb"].each {|file| require file }
Dir["#{APPDIR}/sim/**/*.rb"].each {|file| require file }
Dir["#{APPDIR}/controllers/*.rb"].each {|file| require file }

# Additional log formatting for the models we've loaded
LogFmt.objs[:env] = Environment
LogFmt.objs[:lf] = Lifeform