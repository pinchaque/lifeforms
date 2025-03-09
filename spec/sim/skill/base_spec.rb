include Skill


describe "Base" do

  class TestSkill < Skill::Base
  end

  class TestSkillChild < TestSkill
  end

  context "#id" do

    it "produces correct id" do
      expect(Base.id).to eq("base")
      expect(TestSkill.id).to eq("test_skill")
      expect(TestSkillChild.id).to eq("test_skill_child")
    end
  end
end