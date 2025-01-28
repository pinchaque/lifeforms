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
      steps: 10,
      lfs_json: JSON.generate(env.render_data)
    }
  end

  post '/env/:id' do |id|
    env = Environment.where(id: id).first
    steps = params['steps'].to_i
    env.run_steps(steps) if steps > 0

    erb :"env/viz", :locals => {
      env: env,
      steps: steps,
      lfs_json: JSON.generate(env.render_data)
    }
  end
end