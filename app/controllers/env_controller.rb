class EnvController < AppController

  get '/env' do
    @envs = Environment.all
    erb :"env/index"
  end

  get '/env/:id' do |id|
    @env = Environment.where(id: id).first

    # XXX TODO Need to figure out why this doesn't owrk to pass the variable through to ERB
    @lifeforms = @env.lifeforms.order(:name).all
    erb :"env/id"
  end
end