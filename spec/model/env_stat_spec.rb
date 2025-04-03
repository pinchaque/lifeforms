
describe "EnvStat" do
  let(:tol) { 0.0001 }
  let(:env) { TestFactory.env }
  let(:species_plant) { TestFactory.species('Plant') }
  let(:species_grazer) { TestFactory.species('Grazer') }



  def add_lf(x, y, size = 1.0, energy = 10.0)
    TestFactory.lifeform(env, species, 
      created_step: 1,
      energy: energy,
      size: size,
      x: x,
      y: y,
      )
  end

  context "#snapshot_from_env" do
    it "adds stats" do
      
    end
  end
end