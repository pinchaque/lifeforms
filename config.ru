require './config/environment'

#use UserController
#use OrdersController
use Rack::MethodOverride
use EnvController
run AppController
