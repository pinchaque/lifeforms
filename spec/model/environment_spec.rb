
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
    l.initial_size = 0.2
    l.name = "Incredible Juniper"
    l.x = 0.0
    l.y = 0.0
    l.mark_born
    l.save
  }

  context ".lifeforms" do
    it "returns all lifeforms" do
      tlf.save
      lfs = env.lifeforms
      expect(lfs.count).to eq(1)
      expect(lfs[0].id).to eq(tlf.id)
    end

    it "excludes dead lifeforms" do
      tlf.mark_dead.save
      lfs = env.lifeforms
      expect(lfs.count).to eq(0)      
    end
  end
end