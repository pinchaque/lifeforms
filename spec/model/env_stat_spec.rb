
describe "EnvStat" do
  let(:tol) { 0.0001 }
  let(:time_step) { 3 }
  let(:env) { TestFactory.env(time_step: time_step) }
  let(:plant) { TestFactory.species('Plant') }
  let(:grazer) { TestFactory.species('Grazer') }

  def add_lf(species_id:, **attrs)
    TestFactory.lifeform(environment_id: env.id, species_id: species_id, **attrs)
  end

  context "#snapshot_from_env" do
    it "no lifeforms" do
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(0)
      EnvStat.snapshot_from_env(env)
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(0)
    end

    it "single species, living and dead" do
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(0)

      add_lf(species_id: plant.id, created_step: 2, energy: 10.0, generation: 1)
      add_lf(species_id: plant.id, created_step: 3, energy: 10.0, generation: 3)
      add_lf(species_id: plant.id, created_step: 1, died_step: 2, energy: 10.0, generation: 2)
      add_lf(species_id: plant.id, created_step: 1, died_step: 3, energy: 10.0, generation: 1)
      
      EnvStat.snapshot_from_env(env)
      ess = EnvStat.where(environment_id: env.id).all

      expect(ess.count).to eq(1)

      stats_exp = { 
        environment_id: env.id,
        time_step: 3,
        species_id: plant.id,
        count_living: 2,
        count_dead: 2,
        count_born: 1,
        count_died: 1,
        sum_energy: 20.0,
        max_generation: 3,
        avg_age: 1.0,
        avg_age_living: 0.5
      }
      stats_act = ess[0].values
      stats_act.keep_if { |k, v| stats_exp.key?(k) }

      expect(stats_act).to eq(stats_exp)
    end
  end
end

