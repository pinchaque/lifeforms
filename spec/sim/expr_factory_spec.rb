describe "ExprFactory" do
  TestEFFoo = TestFactory.skill(5.67, {}, [:foo1, :foo2])
  TestEFBar = TestFactory.skill(1.23, {}, [:bar1, :bar2])

  let(:env) { TestFactory.env }
  let(:skills) { [TestEFFoo, TestEFBar] }
  let(:lf) { 
    l = TestFactory.lifeform(environment_id: env.id)
    skills.each { |s| l.register_skill(s) }
    l
  }
  let(:ctx) { Context.new(lf) }
  let(:ef) { ExprFactory.new(ctx) }
  let(:trials) { 500 }

  context ".numeric" do
    it "generates random numeric expression" do
      (0...trials).each do |i|
        expr = ef.numeric
        eval_act = expr.eval(ctx)
        str = "#{expr} => #{eval_act}"
        expect(str).to satisfy('be numeric') do |x| 
          is_numeric?(eval_act)
        end
      end
    end
  end
end
