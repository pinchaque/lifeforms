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
    num_lf = params['lifeforms'].to_i
    width = params['width'].to_i
    height = params['height'].to_i
    energy_rate = params['energy_rate'].to_f
    DB.transaction do
      env = Environment.new(width: width, height: height, energy_rate: energy_rate).save

      [Zoo::Plant, Zoo::Grazer].each do |fact_class|
        pf = fact_class.new(env)
        (0...num_lf).each do
            pf.gen.save
        end
      end
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
    env.run_steps(steps) if steps > 0

    erb :"env/viz", :locals => {
      env: env,
      steps: steps,
      lfs_json: JSON.generate(env.render_data)
    }
  end
end