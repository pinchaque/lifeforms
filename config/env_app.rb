Dir["#{APPDIR}/models/*.rb"].each {|file| require file }
Dir["#{APPDIR}/sim/**/*.rb"].each {|file| require file }
Dir["#{APPDIR}/controllers/*.rb"].each {|file| require file }