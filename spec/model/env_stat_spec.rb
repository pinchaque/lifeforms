
describe "EnvStat" do
  let(:tol) { 0.0001 }
  let(:env) { TestFactory.env }
  let(:species_plant) { TestFactory.species('Plant') }
  let(:species_grazer) { TestFactory.species('Grazer') }



  def add_lf(species_id:, **attrs)
    TestFactory.lifeform(environment_id: env.id, **attrs)
  end

  context "#snapshot_from_env" do
    it "adds stats" do
      
    end
  end
end