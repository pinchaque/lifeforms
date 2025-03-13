include Skill

class TestSkill < Skill::Base
end


describe "SkillSet" do
  let(:ss) { SkillSet.new }
  let(:skill) { TestSkill }
  let(:id) { :test_skill }

  context ".initialize" do
    it "creates empty SkillSet" do
      expect(ss.skills.count).to eq(0)
    end
  end

  context "add/include/value/clear" do
    it "handles basic functionality" do
      # empty to start
      expect(ss.count).to eq(0)
      expect(ss.include?(id)).to be false

      # include the param
      ss.add(skill)
      expect(ss.count).to eq(1)
      expect(ss.include?(id)).to be true

      # back to empty
      ss.clear
      expect(ss.count).to eq(0)
      expect(ss.include?(id)).to be false
    end
  end
end