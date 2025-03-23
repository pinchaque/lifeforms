describe "Shrink" do
  let(:tol) { 0.0001 }
  let(:species) { TestFactory.species }
  let(:env_energy_rate) { 10.0 }
  let(:env) { TestFactory.env(100, 100, 3, env_energy_rate) }
  let(:klass) { Skill::Shrink }
  let(:skill_id) { klass.id }
  let(:shrink_perc) { 0.80 }
  let(:init_size) { 50.0 }

  context "Generic Lifeform" do
    let(:lf) { 
      l = TestFactory.lifeform(env, species) 
      l.register_skill(klass)
      l.params.fetch(:shrink_perc).set(shrink_perc)
      l.size = init_size
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
      it "shrinks as expected" do
        expect(lf.size).to be_within(tol).of(init_size)

        # size = old_size * shrink_perc
        size_exp = 40.0

        # run the action
        expect(klass.eval(ctx)).to be_within(tol).of(size_exp)
        expect(lf.size).to be_within(tol).of(size_exp)
      end
    end
  end
end