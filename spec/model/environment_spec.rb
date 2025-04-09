
describe "Environment" do
  let(:tol) { 0.0001 }
  let(:env) { TestFactory.env }
  let(:lf) { TestFactory.lifeform(environment_id: env.id) }

  context ".lifeforms" do
    it "returns all lifeforms" do
      expect(env.lifeforms.count).to eq(0) # none yet
      lf.save # instantiate
      lfs = env.lifeforms
      expect(lfs.count).to eq(1)
      expect(lfs[0].id).to eq(lf.id)
    end

    it "excludes dead lifeforms" do
      lf.mark_dead.save
      lfs = env.lifeforms
      expect(lfs.count).to eq(0)      
    end
  end
end