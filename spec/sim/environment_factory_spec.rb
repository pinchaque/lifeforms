describe "EnvironmentFactory" do
  let(:tol) { 0.0001 }
  let(:fact) { EnvironmentFactory.new }

  context ".gen" do
    
    it "creates env and spawners" do
      env = fact.gen

      expect(env).not_to be_nil

      spawners = Spawner.where(environment_id: env.id).all
      expect(spawners.count).to eq(2)

      fact.spawner_params.each do |name, prms|
        species = Species.where(name: name).first
        expect(species).not_to be_nil

        spawner = Spawner.where(environment_id: env.id, species_id: species.id).first
        expect(spawner).not_to be_nil
        expect(spawner.p_spawn).to be_within(tol).of(prms[:p_spawn])
        expect(spawner.min_lifeforms).to be_within(tol).of(prms[:min_lifeforms])
        expect(spawner.max_lifeforms).to be_within(tol).of(prms[:max_lifeforms])
      end
    end
  end
end
