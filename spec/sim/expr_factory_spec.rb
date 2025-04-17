describe "ExprFactory" do
  TestEFFoo = TestFactory.skill(5.67, {}, [:foo1, :foo2])
  TestEFBar = TestFactory.skill(1.23, {}, [:bar1, :bar2])
  TestEFQuux = TestFactory.skill(8.90, {}, [:quux1, :quux2])

  let(:env) { TestFactory.env }
  let(:skills) { [TestEFFoo, TestEFBar, TestEFQuux] }
  let(:lf) { 
    l = TestFactory.lifeform(environment_id: env.id)
    skills.each { |s| l.register_skill(s) }
    l
  }
  let(:ctx) { Context.new(lf) }
  let(:ef) { ExprFactory.new(ctx) }
  let(:trials) { 30 }
  let(:mutations) { 30 }
  let(:prob) { 0.5 }

  def dbg(str, trial, mutation, expr)
    #puts("[#{str}/#{trial}/#{mutation}] #{expr}")
  end

  context ".skill" do
    it "generates random skill" do
      (0...trials).each do |t|
        expr = ef.skill
        (0...mutations).each do |m|
          dbg("skill", t, m, expr)
          id_act = expr.id
          ids_exp = skills.map{ |s| s.id }
          expect_in_array(id_act, ids_exp)

          expr = expr.mutate(ctx, prob)
        end
      end
    end
  end

  context ".statement" do
    it "generates random statement" do
      (0...trials).each do |t|
        expr = ef.statement
        (0...mutations).each do |m|
          dbg("statement", t, m, expr)
          expr.eval(ctx) # make sure no exception

          # check top-level class
          classes = ["Expr::If", "Expr::Sequence", "Expr::Skill"]
          expect_in_array(expr.class.to_s, classes)

          expr = expr.mutate(ctx, prob)
        end
      end
    end
  end

  context ".numcmp" do
    it "generates random numeric comparison" do
      (0...trials).each do |t|
        expr = ef.numcmp
        (0...mutations).each do |m|
          dbg("numcmp", t, m, expr)

          eval_act = expr.eval(ctx)
          expect("#{expr} => #{eval_act}").to satisfy('be boolean') do |x| 
            is_boolean?(eval_act)
          end

          # check top-level class
          classes = ["Expr::Equal", "Expr::GT", "Expr::GTE", "Expr::LT", "Expr::LTE"]
          expect_in_array(expr.class.to_s, classes)
          expr = expr.mutate(ctx, prob)
        end
      end
    end
  end

  context ".bool" do
    it "generates random numeric comparison" do
      (0...trials).each do |t|
        expr = ef.bool
        (0...mutations).each do |m|
          dbg("bool", t, m, expr)

          eval_act = expr.eval(ctx)
          expect("#{expr} => #{eval_act}").to satisfy('be boolean') do |x| 
            is_boolean?(eval_act)
          end
          expr = expr.mutate(ctx, prob)
        end
      end
    end
  end

  context ".number" do
    it "generates random numeric expression" do
      (0...trials).each do |t|
        expr = ef.number
        (0...mutations).each do |m|
          dbg("number", t, m, expr)
          eval_act = expr.eval(ctx)
          expect("#{expr} => #{eval_act}").to satisfy('be numeric') do |x| 
            is_numeric?(eval_act)
          end
          expr = expr.mutate(ctx, prob)
        end
      end
    end
  end

  context ".numop" do
    it "generates random numeric expression" do
      (0...trials).each do |t|
        expr = ef.numop
        (0...mutations).each do |m|
          dbg("numop", t, m, expr)
          eval_act = expr.eval(ctx)
          expect("#{expr} => #{eval_act}").to satisfy('be numeric') do |x| 
            is_numeric?(eval_act)
          end
          expr = expr.mutate(ctx, prob)
        end
      end
    end
  end
end
