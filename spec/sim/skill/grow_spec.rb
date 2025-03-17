include Skill

describe "Grow" do
  let(:tol) { 0.0001 }
  let(:species) { TestFactory.species }
  let(:env_energy_rate) { 10.0 }
  let(:env) { TestFactory.env(100, 100, 3, env_energy_rate) }
  let(:klass) { Grow }
  let(:skill_id) { klass.id }
  let(:grow_perc) { 0.10 }
  let(:init_size) { 20.0 }

  context "Generic Lifeform" do
    let(:lf) { 
      l = TestFactory.lifeform(env, species) 
      l.register_skill(Grow)
      l.params.fetch(:grow_perc).value = grow_perc
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

    context ".exec" do
      it "grows as expected" do
        expect(lf.size).to be_within(tol).of(init_size)

        # run the action
        klass.exec(ctx)

        # size = old_size * grow_perc
        expect(lf.size).to be_within(tol).of(22.0)
      end
    end
  end
end