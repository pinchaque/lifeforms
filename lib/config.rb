LIBDIR = File.expand_path('../lib', File.dirname(__FILE__))
TMPDIR = File.expand_path('../tmp', File.dirname(__FILE__))

Dir["#{LIBDIR}/core/*.rb"].each {|file| require file }
Dir["#{LIBDIR}/model/*.rb"].each {|file| require file }
Dir["#{LIBDIR}/zoo/*.rb"].each {|file| require file }
Dir["#{LIBDIR}/sim/*.rb"].each {|file| require file }