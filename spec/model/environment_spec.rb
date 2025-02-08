
describe "Environment" do
  let(:tol) { 0.0001 }
  let(:species) { Species.new(name: "Test Lifeform").save }
  let(:env) { Environment.new(width: 100, height: 100, time_step: 0, energy_rate: 5.0).save }
  let(:tlf) {
    l = TestLF.new
    l.val1 = "foo"
    l.val2 = 42
    l.environment_id = env.id
    l.species_id = species.id
    l.energy = 10.0
    l.size = 1.0
    l.name = "Incredible Juniper"
    l.x = 0.0
    l.y = 0.0
    l.save
  }
end