
describe "EnvStat" do
  let(:tol) { 0.0001 }
  let(:time_step) { 3 }
  let(:env) { TestFactory.env(time_step: time_step) }
  let(:plant) { TestFactory.species(name: 'Plant') }
  let(:grazer) { TestFactory.species(name: 'Grazer') }

  def add_lf(species_id:, **attrs)
    TestFactory.lifeform(environment_id: env.id, species_id: species_id, **attrs)
  end

  context "#snapshot_from_env" do

    def t(stats_act, stats_exp)
      stats_act.keep_if { |k, v| stats_exp.key?(k) }
      cmp_hash(stats_act, stats_exp)
    end

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
      t(ess[0].values, stats_exp)
    end

    it "two species, living and dead" do
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(0)

      add_lf(species_id: plant.id, created_step: 2, energy: 10.0, generation: 1)
      add_lf(species_id: plant.id, created_step: 3, energy: 10.0, generation: 3)
      add_lf(species_id: grazer.id, created_step: 1, died_step: 2, energy: 10.0, generation: 1)
      add_lf(species_id: grazer.id, created_step: 1, energy: 10.0, generation: 1)
      
      EnvStat.snapshot_from_env(env)

      plant_ds = EnvStat.where(environment_id: env.id, time_step: time_step, species_id: plant.id)
      grazer_ds = EnvStat.where(environment_id: env.id, time_step: time_step, species_id: grazer.id)

      expect(plant_ds.count).to eq(1)
      expect(grazer_ds.count).to eq(1)

      plant_stats_exp = { 
        environment_id: env.id,
        time_step: 3,
        species_id: plant.id,
        count_living: 2,
        count_dead: 0,
        count_born: 1,
        count_died: 0,
        sum_energy: 20.0,
        max_generation: 3,
        avg_age: 0.5,
        avg_age_living: 0.5
      }

      grazer_stats_exp = { 
        environment_id: env.id,
        time_step: 3,
        species_id: grazer.id,
        count_living: 1,
        count_dead: 1,
        count_born: 0,
        count_died: 0,
        sum_energy: 10.0,
        max_generation: 1,
        avg_age: 1.5,
        avg_age_living: 2.0
      }

      t(plant_ds.first.values, plant_stats_exp)
      t(grazer_ds.first.values, grazer_stats_exp)
    end

    it "single species, all dead" do
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(0)

      add_lf(species_id: plant.id, created_step: 1, died_step: 2, energy: 10.0, generation: 2)
      add_lf(species_id: plant.id, created_step: 1, died_step: 3, energy: 10.0, generation: 1)
      
      EnvStat.snapshot_from_env(env)
      ess = EnvStat.where(environment_id: env.id).all

      expect(ess.count).to eq(1)

      stats_exp = { 
        environment_id: env.id,
        time_step: 3,
        species_id: plant.id,
        count_living: 0,
        count_dead: 2,
        count_born: 0,
        count_died: 1,
        sum_energy: nil,
        max_generation: 2,
        avg_age: 1.5,
        avg_age_living: nil
      }
      t(ess[0].values, stats_exp)
    end

    it "multiple time_step snapshots" do
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(0)


      lf0 = add_lf(species_id: plant.id, created_step: 1, energy: 10.0, generation: 2)
      lf1 = add_lf(species_id: plant.id, created_step: 1, energy: 10.0, generation: 1)
      env.time_step = 3
      env.save

      # Snapshot 1
      EnvStat.snapshot_from_env(env)

      lf0.died_step = 4
      lf0.energy = 0.0
      lf0.save

      lf1.energy = 15.0
      lf1.save

      add_lf(species_id: plant.id, created_step: 4, energy: 16.0, generation: 3)

      env.time_step = 4
      env.save

      # Snapshot 2
      EnvStat.snapshot_from_env(env)

      # 2 plant snapshots at different steps
      expect(EnvStat.where(environment_id: env.id).count).to eq(2)

      ess3 = EnvStat.where(environment_id: env.id, time_step: 3).first
      expect(ess3).not_to be_nil

      stats3_exp = { 
        environment_id: env.id,
        time_step: 3,
        species_id: plant.id,
        count_living: 2,
        count_dead: 0,
        count_born: 0,
        count_died: 0,
        sum_energy: 20.0,
        max_generation: 2,
        avg_age: 2.0,
        avg_age_living: 2.0
      }
      t(ess3.values, stats3_exp)

      ess4 = EnvStat.where(environment_id: env.id, time_step: 4).first
      expect(ess4).not_to be_nil
      stats4_exp = { 
        environment_id: env.id,
        time_step: 4,
        species_id: plant.id,
        count_living: 2,
        count_dead: 1,
        count_born: 1,
        count_died: 1,
        sum_energy: 31.0,
        max_generation: 3,
        avg_age: (3.0 + 3.0 + 0.0) / 3.0,
        avg_age_living: (3.0 + 0.0) / 2.0
      }
      t(ess4.values, stats4_exp)
    end

    it "handles duplicate snapshots" do
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(0)

      add_lf(species_id: plant.id, created_step: 2, energy: 10.0, generation: 1)
      
      EnvStat.snapshot_from_env(env)
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(1)

      # duplicate
      EnvStat.snapshot_from_env(env)
      ess = EnvStat.where(environment_id: env.id).all
      expect(ess.count).to eq(1)
    end
  end

  context ".to_s" do
    
    it "formats user-friendly string" do
      ess = EnvStat.where(environment_id: env.id).all
      add_lf(species_id: plant.id, created_step: 2, energy: 10.0, generation: 1)
      add_lf(species_id: plant.id, created_step: 3, energy: 10.0, generation: 3)
      add_lf(species_id: plant.id, created_step: 1, died_step: 2, energy: 10.0, generation: 2)
      add_lf(species_id: plant.id, created_step: 1, died_step: 3, energy: 10.0, generation: 1)
      
      EnvStat.snapshot_from_env(env)
      # stats_exp = { 
      #   environment_id: env.id,
      #   time_step: 3,
      #   species_id: plant.id,
      #   count_living: 2,
      #   count_dead: 2,
      #   count_born: 1,
      #   count_died: 1,
      #   sum_energy: 20.0,
      #   max_generation: 3,
      #   avg_age: 1.0,
      #   avg_age_living: 0.5
      # }

      
      ess = EnvStat.where(environment_id: env.id).first

      expect(ess.count_lifeforms).to be_within(tol).of(4)
      expect(ess.perc_alive).to be_within(tol).of(0.5)
      expect(ess.perc_dead).to be_within(tol).of(0.5)

      str_exp = "[TS:3] [Plant] Alive: 2 (+1 -1) | Egy: 20.0 | Age: 0.5 | Dead: 2 (50.0%)"
      expect(ess.to_s).to eq(str_exp)
    end
  end
end