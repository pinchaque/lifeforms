class AppController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    #enable :sessions
    #set :session_secret, "session_secret"
  end

  get '/' do 
    erb :"index"
  end

  get "/status" do
    @str = "active"
    erb :"status"
  end
end