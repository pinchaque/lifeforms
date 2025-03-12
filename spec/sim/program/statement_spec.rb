include Program

describe "Statement" do
  let(:ctx) { {} }
  TestSkillFoo = TestFactory.skill("foo")
  TestSkillBar = TestFactory.skill("bar")
  TestSkillQuux = TestFactory.skill("quux")

  let(:a1) { TestSkillFoo }
  let(:a2) { TestSkillBar }
  let(:a3) { TestSkillQuux }
  let(:t1) { e_true }
  let(:f1) { e_not(e_true) }

  context "Sequence" do
    let(:st) { s_seq(a1, a2, a3) }

    it "executes actions" do
      exp = ["foo", "bar", "quux"]
      expect(st.exec(ctx)).to eq(exp)
    end
  end

  context "If" do
    it "executes true action" do
      st = s_if(t1, a1, a2)
      expect(st.exec(ctx)).to eq("foo")
    end

    it "executes false action" do
      st = s_if(f1, a1, a2)
      expect(st.exec(ctx)).to eq("bar")
    end
  end

  context "Nested Sequence -> If" do
    let(:if1) { s_if(t1, a2, a3) }
    let(:if2) { s_if(f1, a2, a3) }
    let(:st) { s_seq(a1, if1, if2) }

    it "executes actions" do
      exp = ["foo", "bar", "quux"]
      expect(st.exec(ctx)).to eq(exp)
    end 
  end
  
  context "Nested If -> Sequence" do
    let(:seq1) { s_seq(a1, a2, a3) }
    let(:seq2) { s_seq(a3, a2, a1) }

    it "executes true sequence" do
      st = s_if(t1, seq1, seq2)
      expect(st.exec(ctx)).to eq(["foo", "bar", "quux"])
    end 

    it "executes false sequence" do
      st = s_if(f1, seq1, seq2)
      expect(st.exec(ctx)).to eq(["quux", "bar", "foo"])
    end
  end

  context "Skill" do
    let(:skill_class) { TestSkill = TestFactory.skill("return value") }
    let(:s) { s_skill(skill_class.id) }
    let(:lf) { 
      l = MockLifeform.new 
      l.register_skill(skill_class)
      l
    }
    let(:ctx) { Context.new(lf) }

    it "executes test skill" do
      expect(s.exec(ctx)).to eq("return value")
    end
  end
end