describe "ExprBool" do
  let(:h) { {} }

  def t(expr, str_exp, eval_exp)
    expect(expr.to_s).to eq(str_exp)
    expect(expr.eval(h)).to be eval_exp      
  end

  context "Logic Basics" do
    it "True" do
      t(e_true, "true", true)
    end

    it "Not(True)" do
      t(e_not(e_true), "!true", false)
    end

    it "And(True)" do
      t(e_and(e_true), "true", true)
    end

    it "And(Not(True))" do
      t(e_and(e_not(e_true)), "!true", false)
    end

    it "And(True, True, True)" do
      t(e_and(e_true, e_true, e_true), "(true && true && true)", true)
    end

    it "And(True, False, True)" do
      t(e_and(e_true, e_not(e_true), e_true), "(true && !true && true)", false)
    end

    it "And(False, False, False)" do
      t(e_and(e_not(e_true), e_not(e_true), e_not(e_true)), "(!true && !true && !true)", false)
    end

    it "Or(True)" do
      t(e_or(e_true), "true", true)
    end

    it "Or(Not(True))" do
      t(e_or(e_not(e_true)), "!true", false)
    end

    it "Or(True, True, True)" do
      t(e_or(e_true, e_true, e_true), "(true || true || true)", true)
    end

    it "Or(True, False, True)" do
      t(e_or(e_true, e_not(e_true), e_true), "(true || !true || true)", true)
    end

    it "Or(False, False, False)" do
      t(e_or(e_not(e_true), e_not(e_true), e_not(e_true)), "(!true || !true || !true)", false)
    end
  end

  context "Nested Logic" do
    it "And(Or(False, True), Or(True, True))" do
      t(e_and(e_or(e_not(e_true), e_true), e_or(e_true, e_true)), "((!true || true) && (true || true))", true)
    end

    it "Or(And(False, True), And(True, True))" do
      t(e_or(e_and(e_not(e_true), e_true), e_and(e_true, e_true)), "((!true && true) || (true && true))", true)
    end

    it "Or(And(False, True), And(True, False))" do
      t(e_or(e_and(e_not(e_true), e_true), e_and(e_true, e_not(e_true))), "((!true && true) || (true && !true))", false)
    end
  end
  
  context "Numeric Cmp" do
    let(:h) { {
      foo: 1.0,
      bar: 2.0,
      quux: 2.0 
    } }


    it "Equal" do
      t(e_equal(:foo, :foo), "(foo == foo)", true)
      t(e_equal(:bar, :quux), "(bar == quux)", true)
      t(e_equal(:foo, :bar), "(foo == bar)", false)
    end

    it "Less Than" do
      t(e_lt(:foo, :foo), "(foo < foo)", false)
      t(e_lt(:bar, :quux), "(bar < quux)", false)
      t(e_lt(:quux, :bar), "(quux < bar)", false)
      t(e_lt(:foo, :bar), "(foo < bar)", true)
      t(e_lt(:bar, :foo), "(bar < foo)", false)
    end

    it "Less Than Equal" do
      t(e_lte(:foo, :foo), "(foo <= foo)", true)
      t(e_lte(:bar, :quux), "(bar <= quux)", true)
      t(e_lte(:quux, :bar), "(quux <= bar)", true)
      t(e_lte(:foo, :bar), "(foo <= bar)", true)
      t(e_lte(:bar, :foo), "(bar <= foo)", false)
    end

    it "Greater Than" do
      t(e_gt(:foo, :foo), "(foo > foo)", false)
      t(e_gt(:bar, :quux), "(bar > quux)", false)
      t(e_gt(:quux, :bar), "(quux > bar)", false)
      t(e_gt(:foo, :bar), "(foo > bar)", false)
      t(e_gt(:bar, :foo), "(bar > foo)", true)
    end

    it "Greater Than Equal" do
      t(e_gte(:foo, :foo), "(foo >= foo)", true)
      t(e_gte(:bar, :quux), "(bar >= quux)", true)
      t(e_gte(:quux, :bar), "(quux >= bar)", true)
      t(e_gte(:foo, :bar), "(foo >= bar)", false)
      t(e_gte(:bar, :foo), "(bar >= foo)", true)
    end
  end

  context "Complex Nested Expressions" do
    let(:h) { {
      foo: 1.0,
      bar: 2.0,
      quux: 2.0 
    } }

    let(:t1) { e_lt(:foo, :bar) }
    let(:t2) { e_lte(:bar, :quux) }
    let(:t3) { e_gt(:quux, :foo) }
    let(:t4) { e_gte(:quux, :quux) }

    let(:f1) { e_gt(:foo, :bar) }
    let(:f2) { e_gt(:foo, :foo) }
    let(:f3) { e_lt(:quux, :bar) }
    let(:f4) { e_lte(:bar, :foo) }

    it "Basic Exprs" do
      t(t1, "(foo < bar)", true)
      t(t2, "(bar <= quux)", true)
      t(t3, "(quux > foo)", true)
      t(t4, "(quux >= quux)", true)

      t(f1, "(foo > bar)", false)
      t(f2, "(foo > foo)", false)
      t(f3, "(quux < bar)", false)
      t(f4, "(bar <= foo)", false)
    end

    let(:t5) { e_and(t1, t2) }
    let(:t6) { e_not(f1) }
    let(:t7) { e_or(f1, f2, f3, f4, t3) }
    let(:t8) { e_and(t4, t3, t2, t1) }

    let(:f5) { e_and(t3, f4, f3) }
    let(:f6) { e_not(t3) }
    let(:f7) { e_or(f1, f2, f3, f4) }
    let(:f8) { e_and(f1, f2) }

    it "Single Level" do
      t(t5, "((foo < bar) && (bar <= quux))", true)
      t(t6, "!(foo > bar)", true)
      t(t7, "((foo > bar) || (foo > foo) || (quux < bar) || (bar <= foo) || (quux > foo))", true)
      t(t8, "((quux >= quux) && (quux > foo) && (bar <= quux) && (foo < bar))", true)

      t(f5, "((quux > foo) && (bar <= foo) && (quux < bar))", false)
      t(f6, "!(quux > foo)", false)
      t(f7, "((foo > bar) || (foo > foo) || (quux < bar) || (bar <= foo))", false)
      t(f8, "((foo > bar) && (foo > foo))", false)
    end

    let(:t9) { e_and(t6, t8) }
    let(:t10) { e_or(f6, f8, t5) }

    let(:f9) { e_and(t6, t8, f6) }
    let(:f10) { e_not(t8) }

    it "Two Levels" do
      t(t9, "(!(foo > bar) && ((quux >= quux) && (quux > foo) && (bar <= quux) && (foo < bar)))", true)
      t(t10, "(!(quux > foo) || ((foo > bar) && (foo > foo)) || ((foo < bar) && (bar <= quux)))", true)

      t(f9, "(!(foo > bar) && ((quux >= quux) && (quux > foo) && (bar <= quux) && (foo < bar)) && !(quux > foo))", false)
      t(f10, "!((quux >= quux) && (quux > foo) && (bar <= quux) && (foo < bar))", false)
    end
  end

  context "Exceptions" do
    let(:h) { {
      foo: 1.0,
      bar: 2.0,
      quux: 2.0,
      str: "non numeric string",
      emptystr: nil
    } }

    def t_err(e, str_exp, exception_exp)
      expect(e.to_s).to eq(str_exp)
      expect{e.eval(h)}.to raise_error(exception_exp)
    end

    it "Missing Value" do
      t_err(e_lt(:foo, :xxx), "(foo < xxx)", "Missing value for symbol 'xxx'")
    end

    it "Non-numeric Value" do
      t_err(e_lt(:foo, :str), "(foo < str)", "Value for 'str' is not numeric ('non numeric string')")
    end

    it "Non-numeric Value" do
      t_err(e_lt(:foo, :emptystr), "(foo < emptystr)", "Value for 'emptystr' is nil")
    end
  end

  context "Marshaling" do
    def t_marshal(expr, exp)
      act = expr.marshal
      expect(act).to eq(exp)

      expr_new = ExprBool::Base.unmarshal(act)
      expect(expr_new.to_s).to eq(expr.to_s)
    end

    it ".short_class_name" do
      expect(e_true.short_class_name).to eq("True")
      expect(e_gt(:foo, :foo).short_class_name).to eq("GT")
      expect(e_and(e_true).short_class_name).to eq("And")
    end

    it "#full_class_name" do
      expect(ExprBool::Base.full_class_name("And")).to eq("ExprBool::And")
    end

    it "True" do
      t_marshal(e_true, {t: "True"})
    end

    it "Not(True)" do
      t_marshal(e_not(e_true), {t: "Not", v: {t: "True"}})
    end

    it "And(True)" do
      t_marshal(e_and(e_true), {t: "And", v: [{t: "True"}]})
    end

    it "Or(True)" do
      t_marshal(e_or(e_true), {t: "Or", v: [{t: "True"}]})
    end

    it "And(Or(True, Not(True)), Or(True, True))" do
      exp = {t: "And", v: [
        {t: "Or", v: [{t: "True"}, {t: "Not", v: {t: "True"}}]},
        {t: "Or", v: [{t: "True"}, {t: "True"}]}]}
      t_marshal(e_and(e_or(e_true, e_not(e_true)), e_or(e_true, e_true)), exp)
    end

    it "NumCmp classes" do
      t_marshal(e_equal(:foo, :bar), {t: "Equal", v: {l: :foo, r: :bar}})
      t_marshal(e_lt(:foo, :bar), {t: "LT", v: {l: :foo, r: :bar}})
      t_marshal(e_lte(:foo, :bar), {t: "LTE", v: {l: :foo, r: :bar}})
      t_marshal(e_gt(:bar, :foo), {t: "GT", v: {l: :bar, r: :foo}})
      t_marshal(e_gte(:bar, :foo), {t: "GTE", v: {l: :bar, r: :foo}})
    end

    it "Combined logic & NumCmp" do
      expr = e_or(
        e_and(e_lt(:foo, :bar), e_lte(:bar, :quux)),
        e_and(e_gt(:foo, :bar), e_gte(:foo, :quux))
      )

      t_marshal(expr, {t: "Or", v: 
        [
          {:t => "And", :v => [
            {:t => "LT", :v => {:l => :foo, :r => :bar}}, 
            {:t => "LTE", :v => {:l => :bar, :r => :quux}}]},
          {:t => "And", :v => [
            {:t => "GT", :v => {:l => :foo, :r => :bar}}, 
            {:t => "GTE", :v => {:l => :foo, :r => :quux}}]}
        ]})
    end
  end
end