include Program

describe "Statement" do
  TestSkillFoo = TestFactory.skill("foo")
  TestSkillBar = TestFactory.skill("bar")
  TestSkillQuux = TestFactory.skill("quux")

  let(:lf) { 
    l = MockLifeform.new 
    l.register_skill(TestSkillFoo)
    l.register_skill(TestSkillBar)
    l.register_skill(TestSkillQuux)
    l
  }
  let(:ctx) { Context.new(lf) }

  let(:a1) { Program.s_skill(TestSkillFoo.id) }
  let(:a2) { Program.s_skill(TestSkillBar.id) }
  let(:a3) { Program.s_skill(TestSkillQuux.id) }
  let(:t1) { e_true }
  let(:f1) { e_not(e_true) }

  def t_exec(st, ctx, exp)
    if exp.nil?
      expect(st.exec(ctx)).to be_nil
    else
      expect(st.exec(ctx)).to eq(exp)
    end
  end

  def t_marshal(st, exp)
    act = st.marshal
    expect(act).to eq(exp)
    st_new = Program::Statement::Base.unmarshal(act)
    expect(st_new.marshal).to eq(act)
  end

  context "Base" do
    it ".short_class_name" do
      expect(Program.s_noop.short_class_name).to eq("Noop")
      expect(Program.s_seq(a1, a2, a3).short_class_name).to eq("Sequence")
      expect(Program.s_skill(TestSkillFoo.id).short_class_name).to eq("Skill")
    end

    it "#full_class_name" do
      expect(Program::Statement::Base.full_class_name("Noop")).to eq("Program::Statement::Noop")
    end
  end

  context "Noop" do
    let(:st) { Program.s_noop }
    it "executes actions" do
      t_exec(st, ctx, nil)
    end

    it "marshals/unmarshals" do
      t_marshal(Program.s_noop, {t: "Noop"})
    end
  end

  context "Skill" do
    let(:st) { Program.s_skill(TestSkillFoo.id) }

    it "executes action" do
      t_exec(st, ctx, "foo")
    end

    it "marshals/unmarshals" do
      t_marshal(st, {t: "Skill", v: :test_skill_foo})
    end
  end

  context "Sequence" do
    let(:st) { Program.s_seq(a1, a2, a3) }

    it "executes actions" do
      t_exec(st, ctx, ["foo", "bar", "quux"])
    end

    it "marshals/unmarshals" do
      exp = {t: "Sequence", v: [
        {:t => "Skill", :v => :test_skill_foo}, 
        {:t => "Skill", :v => :test_skill_bar}, 
        {:t => "Skill", :v => :test_skill_quux}
      ]}
      t_marshal(st, exp)
    end
  end

  context "If" do
    it "executes true action" do
      st = Program.s_if(t1, a1, a2)
      t_exec(st, ctx, "foo")
    end

    it "executes false action" do
      st = Program.s_if(f1, a1, a2)
      t_exec(st, ctx, "bar")
    end
  
    it "marshals/unmarshals - true" do
      exp = {t: "If", v: {
        if: {t: "True"},
        then: {:t => "Skill", :v => :test_skill_foo},
        else: {:t => "Skill", :v => :test_skill_bar}
      }}
      t_marshal(Program.s_if(t1, a1, a2), exp)
    end
  
    it "marshals/unmarshals - false" do
      exp = {t: "If", v: {
        if: {t: "Not", v: {t: "True"}},
        then: {:t => "Skill", :v => :test_skill_foo},
        else: {:t => "Skill", :v => :test_skill_bar}
      }}
      t_marshal(Program.s_if(f1, a1, a2), exp)
    end
  end

  context "Nested Sequence -> If" do
    let(:if1) { Program.s_if(t1, a2, a3) }
    let(:if2) { Program.s_if(f1, a2, a3) }
    let(:st) { Program.s_seq(a1, if1, if2) }

    it "executes actions" do
      t_exec(st, ctx, ["foo", "bar", "quux"])
    end 

    it "marshals/unmarshals" do
      exp = {
        t: "Sequence",
        v: [
          {:t => "Skill", :v => :test_skill_foo}, 
          {:t => "If", :v => {
            :if => {:t => "True"}, 
            :then => {:t => "Skill", :v => :test_skill_bar},
            :else => {:t => "Skill", :v => :test_skill_quux}}}, 
          {:t => "If", :v => {
            :if => {:t => "Not", :v => {:t => "True"}}, 
            :then => {:t => "Skill", :v => :test_skill_bar},
            :else => {:t => "Skill", :v => :test_skill_quux}}}
          ]
      }
      t_marshal(st, exp)
    end
  end
  
  context "Nested If -> Sequence" do
    let(:seq1) { Program.s_seq(a1, a2, a3) }
    let(:seq2) { Program.s_seq(a3, a2, a1) }

    it "executes true sequence" do
      t_exec(Program.s_if(t1, seq1, seq2), ctx, ["foo", "bar", "quux"])
    end 

    it "executes false sequence" do
      t_exec(Program.s_if(f1, seq1, seq2), ctx, ["quux", "bar", "foo"])
    end
  end
end