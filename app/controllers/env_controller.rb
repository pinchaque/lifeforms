require 'json'
class EnvController < AppController

  get '/env' do
    # use defaults from EnvironmentFactory
    ef = EnvironmentFactory.new

    erb :"env/index", :locals => {
      envs: Environment.order(:created_at).reverse.all,
      lifeforms: 6,
      width: ef.width,
      height: ef.height,
      energy_rate: ef.energy_rate
    }
  end

  post '/env' do
    width = params['width'].to_i
    height = params['height'].to_i
    energy_rate = params['energy_rate'].to_f
    DB.transaction do
      ef = EnvironmentFactory.new
      ef.width = width
      ef.height = height
      ef.energy_rate = energy_rate
      env = ef.gen
      redirect to("/env/#{env.id}")
    end
  end

  get '/env/:id' do |id|
    env = Environment.where(id: id).first

    erb :"env/viz", :locals => {
      env: env,
      steps: 1,
      lfs_json: JSON.generate(env.render_data)
    }
  end

  post '/env/:id' do |id|
    env = Environment.where(id: id).first
    steps = params['steps'].to_i
    (0...steps).each do
      env.run_step
      env.log_stats(Scribe::Level::INFO)    
    end
    env.log_self(Scribe::Level::INFO)

    erb :"env/viz", :locals => {
      env: env,
      steps: steps,
      lfs_json: JSON.generate(env.render_data)
    }
  end
end