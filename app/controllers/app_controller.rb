class AppController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    #enable :sessions
    #set :session_secret, "session_secret"
  end

  get '/' do 
    "Hello, World!"
  end

  get "/status" do
    # Render posts index view 
    @str = "active"
    erb :"status"
  end
end