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
  let(:trials) { 10 }

  def dbg(str, i, expr)
    puts("[#{str}/#{i}] #{expr}")
  end


  context ".skill" do
    it "generates random skill" do
      (0...trials).each do |i|
        expr = ef.skill
        dbg("skill", i, expr)
        id_act = expr.id
        ids_exp = skills.map{ |s| s.id }
        expect_in_array(id_act, ids_exp)
      end
    end
  end

  context ".statement" do
    it "generates random statement" do
      (0...trials).each do |i|
        expr = ef.statement
        dbg("statement", i, expr)
        expr.eval(ctx) # make sure no exception

        # check top-level class
        classes = ["Expr::If", "Expr::Sequence", "Expr::Skill"]
        expect_in_array(expr.class.to_s, classes)
      end
    end
  end

  context ".numcmp" do
    it "generates random numeric comparison" do
      (0...trials).each do |i|
        expr = ef.numcmp
        dbg("numcmp", i, expr)

        eval_act = expr.eval(ctx)
        expect("#{expr} => #{eval_act}").to satisfy('be boolean') do |x| 
          is_boolean?(eval_act)
        end

        # check top-level class
        classes = ["Expr::Equal", "Expr::GT", "Expr::GTE", "Expr::LT", "Expr::LTE"]
        expect_in_array(expr.class.to_s, classes)
      end
    end
  end

  context ".bool" do
    it "generates random numeric comparison" do
      (0...trials).each do |i|
        expr = ef.bool
        dbg("bool", i, expr)

        eval_act = expr.eval(ctx)
        expect("#{expr} => #{eval_act}").to satisfy('be boolean') do |x| 
          is_boolean?(eval_act)
        end
      end
    end
  end

  context ".number" do
    it "generates random numeric expression" do
      (0...trials).each do |i|
        expr = ef.number
        dbg("number", i, expr)
        eval_act = expr.eval(ctx)
        expect("#{expr} => #{eval_act}").to satisfy('be numeric') do |x| 
          is_numeric?(eval_act)
        end
      end
    end
  end

  context ".numop" do
    it "generates random numeric expression" do
      (0...trials).each do |i|
        expr = ef.numop
        dbg("numop", i, expr)
        eval_act = expr.eval(ctx)
        expect("#{expr} => #{eval_act}").to satisfy('be numeric') do |x| 
          is_numeric?(eval_act)
        end
      end
    end
  end
end
