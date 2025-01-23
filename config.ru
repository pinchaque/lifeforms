require './config/environment'

#use UserController
#use OrdersController
use Rack::MethodOverride
run AppController
