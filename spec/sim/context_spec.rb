describe "Context" do
  let(:tol) { 0.0001 }
  let(:ret) { "Context return value" }
  let(:env) { TestFactory.env }
  let(:obs_id) { :ctx_obs_id }
  let(:obs_val) { 1.23 }
  ContextTestObs1 = TestFactory.obs(1.23)
  let(:lf) { 
    l = TestFactory.lifeform(environment_id: env.id) 
    l.observations[obs_id] = ContextTestObs1
    l
  }
  let(:ctx) { Context.new(lf) }

  context ".value" do
    let(:dflt) { 'bogus default xxx' }
    it "returns value from params" do
      # no skills or params yet
      expect(lf.skills.count).to eq(0)
      expect(lf.params.count).to eq(0)
      expect(ctx.value(:param1)).to be_nil
      expect(ctx.value(:param2)).to be_nil
      expect(ctx.value(:param3)).to be_nil
      expect(ctx.value(:param1, dflt)).to eq(dflt)
      expect(ctx.value(:param2, dflt)).to eq(dflt)
      expect(ctx.value(:param3, dflt)).to eq(dflt)

      ContextTestSkill = TestFactory.skill(ret)
      lf.register_skill(ContextTestSkill)

      # sanity-check
      expect(lf.skills.count).to eq(1)
      expect(lf.params.count).to eq(2)
      expect(ctx.value(:param1)).to be_between(0.0, 1.0).inclusive
      expect(ctx.value(:param2)).to be_between(0.0, 1.0).inclusive
      expect(ctx.value(:param3)).to be_nil
      expect(ctx.value(:param1, dflt)).to be_between(0.0, 1.0).inclusive
      expect(ctx.value(:param2, dflt)).to be_between(0.0, 1.0).inclusive
      expect(ctx.value(:param3, dflt)).to eq(dflt)
    end

    it "returns value from attrs" do
      # this doesn't test all the attrs as that's done in lifeform_spec
      expect(ctx.value(:lf_energy)).to be_within(tol).of(lf.energy)
      expect(ctx.value(:lf_x)).to be_within(tol).of(lf.x)
    end

    it "returns value from observations" do
      expect(ctx.value(obs_id)).to be_within(tol).of(obs_val)
    end
  end

  context ".keys" do
    it "returns all keys" do
      TestSkillContext = TestFactory.skill(5.67)
      lf.register_skill(TestSkillContext)
      lf.save
      keys_exp = [:param1, :param2, :lf_energy, :lf_age, :lf_metabolic_energy, :lf_size, :lf_generation, :lf_initial_size, :lf_x, :lf_y, :ctx_obs_id]
      expect(ctx.keys).to eq(keys_exp)
    end
  end
end
