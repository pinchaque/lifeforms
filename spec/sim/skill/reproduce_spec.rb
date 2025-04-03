describe "Reproduce" do
  let(:tol) { 0.0001 }
  let(:species) { TestFactory.species }
  let(:env_energy_rate) { 10.0 }
  let(:time_step) { 5 }
  let(:env) { TestFactory.env(time_step: time_step, energy_rate: env_energy_rate) }
  let(:klass) { Skill::Reproduce }
  let(:skill_id) { klass.id }
  let(:energy_parent) { 50.0 }
  let(:size_parent) { 22.2 }
  let(:repro_num_offspring) { 1 }
  let(:repro_energy_inherit_perc) { 0.8 }

  let(:lf) { 
    l = TestFactory.lifeform(env, species) 
    l.register_skill(klass)
    l.params.fetch(:repro_num_offspring).set(repro_num_offspring)
    l.params.fetch(:repro_energy_inherit_perc).set(repro_energy_inherit_perc)
    l.size = size_parent
    l.energy = energy_parent
    l.save
    l
  }
  let(:ctx) { lf.context }

  context "Lifeform.register_skill" do
    it "registers successfully" do
      expect(lf.skills.include?(skill_id))
      klass.param_defs.each do |pd|
        expect(lf.params.include?(pd.id)).to be true
      end
    end
  end

  context ".eval" do
    context "single offspring" do
      let(:repro_num_offspring) { 1 }

      it "generates offspring" do
        expect(lf.energy).to be_within(tol).of(50.0)
        expect(lf.children.count).to eq(0)

        expect(klass.offspring_energy_tot(ctx)).to eq(40.0)
        expect(klass.offspring_energy_each(ctx)).to eq(40.0)

        # energy = old_energy * (1.0 - repro_energy_inherit_perc)
        energy_exp = 10.0

        # run the action
        expect(klass.eval(ctx)).to be_within(tol).of(energy_exp)
        expect(lf.energy).to be_within(tol).of(energy_exp)

        expect(lf.children.count).to eq(repro_num_offspring)
        lf.children.each do |c|
          expect(c.parent_id).to eq(lf.id)
          expect(c.energy).to be_within(tol).of(40.0)
          expect(c.size).to be_within(tol).of(lf.initial_size) # starting size
          expect(c.generation).to eq(lf.generation + 1)
          expect(c.created_step).to eq(env.time_step)
          expect(c.id).not_to be_nil # saved
        end
      end
    end
    
    context "multiple offspring" do
      let(:repro_num_offspring) { 10 }

      it "generates offspring" do
        expect(lf.energy).to be_within(tol).of(50.0)
        expect(lf.children.count).to eq(0)

        expect(klass.offspring_energy_tot(ctx)).to eq(40.0)
        expect(klass.offspring_energy_each(ctx)).to eq(4.0)

        # energy = old_energy * (1.0 - repro_energy_inherit_perc)
        energy_exp = 10.0

        # run the action
        expect(klass.eval(ctx)).to be_within(tol).of(energy_exp)
        expect(lf.energy).to be_within(tol).of(energy_exp)

        expect(lf.children.count).to eq(repro_num_offspring)
        lf.children.each do |c|
          expect(c.parent_id).to eq(lf.id)
          expect(c.energy).to be_within(tol).of(4.0)
          expect(c.size).to be_within(tol).of(lf.initial_size) # starting size
          expect(c.generation).to eq(lf.generation + 1)
          expect(c.created_step).to eq(env.time_step)
          expect(c.id).not_to be_nil # saved

          # child should have same params
          expect(c.params.ids.sort).to eq(lf.params.ids.sort)

          # check that the float parameter has been mutated
          # note that :repro_num_offspring is an int and may be the same
          expect(c.params.fetch(:repro_energy_inherit_perc).value).not_to eq(lf.params.fetch(:repro_energy_inherit_perc).value)
        end
      end
    end
  end
end