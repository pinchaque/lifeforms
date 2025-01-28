require 'json'
class EnvController < AppController

  get '/env' do
    @envs = Environment.all
    erb :"env/index"
  end

  get '/env/:id' do |id|
    env = Environment.where(id: id).first

    erb :"env/viz", :locals => {
      env: env, 
      lifeforms: env.lifeforms.order(:name).all,
      lfs_json: JSON.generate(env.render_data),
      scale: 3.0
    }
  end
end