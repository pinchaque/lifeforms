class EnvController < AppController

  get '/env' do
    @envs = Environment.all
    erb :"env/index"
  end

  get '/env/:id' do |id|
    env = Environment.where(id: id).first

    erb :"env/id", :locals => {
      env: env, 
      lifeforms: env.lifeforms.order(:name).all,
      scale: 3.0
    }
  end
end