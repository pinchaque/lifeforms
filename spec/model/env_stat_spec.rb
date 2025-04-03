
describe "EnvStat" do
  let(:tol) { 0.0001 }
  let(:env) { TestFactory.env }
  let(:species_plant) { TestFactory.species('Plant') }
  let(:species_grazer) { TestFactory.species('Grazer') }


  def add_lf(x, y, size = 1.0, energy = 10.0)
    lf = Lifeform.new
    lf.environment_id = env.id
    lf.created_step = 1
    lf.species_id = species.id
    lf.energy = energy
    lf.size = size
    lf.initial_size = 0.2
    lf.x = x
    lf.y = y
    lf.name = sprintf("add_lf(%f, %f, %f, %f)", x, y, size, energy)
    lf.energy_base = 1.0
    lf.energy_exp = 3.0
    lf.save
    lf
  end

  context "#snapshot_from_env" do
    it "adds stats" do
      
    end
  end
end