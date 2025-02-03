
describe "Plant" do
  let(:tol) { 0.0001 }
  let(:species) { Species.new(name: "Test Lifeform").save }
  let(:env) { Environment.new(width: 100, height: 100, time_step: 0).save }
  let(:tlf) {
    l = TestLF.new
    l.val1 = "foo"
    l.val2 = 42
    l.environment_id = env.id
    l.species_id = species.id
    l.energy = 10.0
    l.size = 1.0
    l.name = "Incredible Juniper"
    l.save
  }
  let(:loc) {
    LifeformLoc.new(x: 9.9, y: 7.7, lifeform_id: tlf.id, environment_id: env.id).save
  }
end