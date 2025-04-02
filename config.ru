require './config/environment'
Log.routers << Scribe::Router.new(
    Scribe::Level::WARNING, 
    Scribe::Formatter.new, 
    Scribe::Outputter::Stderr.new)

#use UserController
#use OrdersController
use Rack::MethodOverride
use EnvController
run AppController
