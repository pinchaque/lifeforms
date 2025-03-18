class TestSkill < Skill::Base
end

class TestSkill2 < Skill::Base
end

describe "SkillSet" do
  let(:ss) { SkillSet.new }
  let(:skill) { TestSkill }
  let(:id) { :test_skill }

  context ".initialize" do
    it "creates empty SkillSet" do
      expect(ss.count).to eq(0)
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

  context "marshalling" do
    it "marshals and unmarshals" do
      ss.add(TestSkill)
      ss.add(TestSkill2)
      expect(ss.count).to eq(2)

      m_exp = [
        TestSkill.name,
        TestSkill2.name
      ]
      m_act = ss.marshal
      expect(m_act).to eq(m_exp)

      # execute a round trip through JSON like we would for the db
      m_act_json = JSON.parse(JSON.generate(m_act), {symbolize_names: true})

      ss_new = SkillSet.unmarshal(m_act_json)
      expect(ss_new.count).to eq(2)
      expect(ss_new.include?(TestSkill.id)).to be true
      expect(ss_new.include?(TestSkill2.id)).to be true
    end
  end
end