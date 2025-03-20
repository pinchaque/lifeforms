describe "Base" do
  context "#id" do
    class TestSkill < Skill::Base
    end

    class TestSkillChild < TestSkill
    end

    it "produces correct id" do
      expect(Skill::Base.id).to eq(:base)
      expect(TestSkill.id).to eq(:test_skill)
      expect(TestSkillChild.id).to eq(:test_skill_child)
    end
  end

  context "marshaling" do
    it "marshals" do
      expect(TestSkill.marshal).to eq("TestSkill")
      expect(TestSkillChild.marshal).to eq("TestSkillChild")
    end

    it "unmarshals" do
      expect(Skill::Base.unmarshal("TestSkill").name).to eq(TestSkill.name)
      expect(Skill::Base.unmarshal("TestSkillChild").name).to eq(TestSkillChild.name)
    end
  end

  # sanith-check tests of our TestFactory
  context "TestFactory" do
    let(:ret) { "test return value" }
    let(:ctx) { nil }

    it "Creates expected TestSkill" do
      BaseTestSkill = TestFactory.skill(ret)

      expect(BaseTestSkill.id).to eq(:base_test_skill)
      expect(BaseTestSkill.eval(ctx)).to eq(ret)
      pds = BaseTestSkill.param_defs
      expect(pds.count).to eq(2)
    end
  end
end