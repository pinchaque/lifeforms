require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Skill" do
  TestSkillFoo = TestFactory.skill(5.67)
  TestSkillBar = TestFactory.skill(1.23)

  let(:lf) { 
    l = MockLifeform.new 
    l.register_skill(TestSkillFoo)
    l.register_skill(TestSkillBar)
    l
  }
  let(:ctx) { Context.new(lf) }

  context "TestSkillFoo" do
    it_behaves_like "expr" do
      let(:expr) { e_skill(TestSkillFoo.id) }
      let(:eval_exp) { 5.67 }
      let(:str_exp) { "SKILL(test_skill_foo)" }
      let(:marshal_exp) { {c: "Skill", v: :test_skill_foo} }
    end
  end

  context "TestSkillBar" do
    it_behaves_like "expr" do
      let(:expr) { e_skill(TestSkillBar.id) }
      let(:eval_exp) { 1.23 }
      let(:str_exp) { "SKILL(test_skill_bar)" }
      let(:marshal_exp) { {c: "Skill", v: :test_skill_bar} }
    end
  end
end