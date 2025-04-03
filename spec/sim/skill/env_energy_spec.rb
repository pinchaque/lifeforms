describe "EnvEnergy" do
  let(:tol) { 0.0001 }
  let(:species) { TestFactory.species }
  let(:env_energy_rate) { 10.0 }
  let(:env) { TestFactory.env(energy_rate: env_energy_rate) }
  let(:klass) { Skill::EnvEnergy }
  let(:skill_id) { klass.id }
  let(:energy_absorb_perc) { 0.50 }

  context "Generic Lifeform" do
    let(:lf) { 
      l = TestFactory.lifeform(env, species) 
      l.register_skill(klass)
      l.params.fetch(:energy_absorb_perc).set(energy_absorb_perc)
      l
    }
    let(:ctx) { lf.context }

    context "Lifeform.register_skill" do
      it "registers successfully" do
        expect(lf.skills.include?(skill_id))
        klass.param_defs.each do |pd|
          expect(lf.params.include?(pd.id)).to be true
        end

        expect(lf.observations.include?(:env_energy)).to be true
      end
    end

    context ".eval" do
      it "has correct energy calcs" do
        expect(lf.energy).to be_within(tol).of(10.0)
        expect(lf.size).to be_within(tol).of(1.0)
        expect(lf.radius).to be_within(tol).of(0.5)
        expect(lf.area).to be_within(tol).of(0.7853981633974483)
        expect(Obs::EnvEnergy.calc(ctx)).to be_within(tol).of(7.853981633974483)
        absorb_perc = lf.params.fetch(:energy_absorb_perc).value
        expect(absorb_perc).to be_within(tol).of(0.5)
        expect(klass.energy_absorb(ctx)).to be_within(tol).of(3.9269908169872414)

        # energy = old_energy + energy_absorb
        energy_exp = 13.9269908169872414

        # run the action
        expect(klass.eval(ctx)).to be_within(tol).of(energy_exp)
        expect(lf.energy).to be_within(tol).of(energy_exp)
      end
    end
  end
end