require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Skill" do
  TestSkillFoo = TestFactory.skill(5.67, {}, [:foo1, :foo2])
  TestSkillBar = TestFactory.skill(1.23, {}, [:bar1, :bar2])
  TestSkillQuux = TestFactory.skill(8.90, {}, [:quux1, :quux2])

  let(:env) { TestFactory.env }
  let(:skills) { [TestSkillFoo, TestSkillBar] }
  let(:lf) { 
    l = TestFactory.lifeform(environment_id: env.id)
    skills.each { |s| l.register_skill(s) }
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

  context ".mutate_real" do
    context "several keys to choose from" do
      let(:skills) { [TestSkillFoo, TestSkillBar, TestSkillQuux] }
      it "uses different id" do
        id1 = TestSkillFoo.id
        expr = e_skill(TestSkillFoo.id)
        expr.mutate_real(ctx)
        expect(expr.id).not_to eq(id1)
      end
    end

    context "only one key" do
      let(:skills) { [TestSkillFoo] }
      it "changes nothing" do
        id1 = TestSkillFoo.id
        expr = e_skill(TestSkillFoo.id)
        expr.mutate_real(ctx)
        expect(expr.id).to eq(id1)
      end
    end
  end
end