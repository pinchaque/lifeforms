require './config/environment'
Log.routers << Scribe::Router.new(
    Scribe::Level::WARNING, 
    LogFmt, 
    Scribe::Outputter::Stderr.new)

use Rack::MethodOverride
use EnvController
run AppController
