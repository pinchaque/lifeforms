describe "Expr" do
  let(:tol) { 0.0001 }
  let(:ctx) { {} }
  let(:e_foo) { e_lookup(:foo) }
  let(:e_bar) { e_lookup(:bar) }
  let(:e_quux) { e_lookup(:quux) }
  let(:e_str) { e_lookup(:str) }
  let(:e_empty) { e_lookup(:empty) }

  def t(expr, str_exp, eval_exp)
    expect(expr.to_s).to eq(str_exp)
    expect(expr.eval(ctx)).to be eval_exp      
  end

  def t_num(expr, str_exp, eval_exp, marshal_exp)
    expect(expr.to_s).to eq(str_exp)
    expect(expr.eval(ctx)).to be_within(tol).of(eval_exp)
    expect(expr.marshal).to eq(marshal_exp)
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
    let(:ctx) { {
      foo: 1.0,
      bar: 2.0,
      quux: 2.0 
    } }


    it "Equal" do
      t(e_equal(e_foo, e_foo), "(foo == foo)", true)
      t(e_equal(e_bar, e_quux), "(bar == quux)", true)
      t(e_equal(e_foo, e_bar), "(foo == bar)", false)
    end

    it "Less Than" do
      t(e_lt(e_foo, e_foo), "(foo < foo)", false)
      t(e_lt(e_bar, e_quux), "(bar < quux)", false)
      t(e_lt(e_quux, e_bar), "(quux < bar)", false)
      t(e_lt(e_foo, e_bar), "(foo < bar)", true)
      t(e_lt(e_bar, e_foo), "(bar < foo)", false)
    end

    it "Less Than Equal" do
      t(e_lte(e_foo, e_foo), "(foo <= foo)", true)
      t(e_lte(e_bar, e_quux), "(bar <= quux)", true)
      t(e_lte(e_quux, e_bar), "(quux <= bar)", true)
      t(e_lte(e_foo, e_bar), "(foo <= bar)", true)
      t(e_lte(e_bar, e_foo), "(bar <= foo)", false)
    end

    it "Greater Than" do
      t(e_gt(e_foo, e_foo), "(foo > foo)", false)
      t(e_gt(e_bar, e_quux), "(bar > quux)", false)
      t(e_gt(e_quux, e_bar), "(quux > bar)", false)
      t(e_gt(e_foo, e_bar), "(foo > bar)", false)
      t(e_gt(e_bar, e_foo), "(bar > foo)", true)
    end

    it "Greater Than Equal" do
      t(e_gte(e_foo, e_foo), "(foo >= foo)", true)
      t(e_gte(e_bar, e_quux), "(bar >= quux)", true)
      t(e_gte(e_quux, e_bar), "(quux >= bar)", true)
      t(e_gte(e_foo, e_bar), "(foo >= bar)", false)
      t(e_gte(e_bar, e_foo), "(bar >= foo)", true)
    end
  end

  context "Complex Nested Expressions" do
    let(:ctx) { {
      foo: 1.0,
      bar: 2.0,
      quux: 2.0 
    } }

    let(:t1) { e_lt(e_foo, e_bar) }
    let(:t2) { e_lte(e_const(1.5), e_quux) }
    let(:t3) { e_gt(e_quux, e_foo) }
    let(:t4) { e_gte(e_quux, e_quux) }

    let(:f1) { e_gt(e_foo, e_bar) }
    let(:f2) { e_gt(e_foo, e_foo) }
    let(:f3) { e_lt(e_quux, e_bar) }
    let(:f4) { e_lte(e_bar, e_foo) }

    it "Basic Exprs" do
      t(t1, "(foo < bar)", true)
      t(t2, "(1.5 <= quux)", true)
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
      t(t5, "((foo < bar) && (1.5 <= quux))", true)
      t(t6, "!(foo > bar)", true)
      t(t7, "((foo > bar) || (foo > foo) || (quux < bar) || (bar <= foo) || (quux > foo))", true)
      t(t8, "((quux >= quux) && (quux > foo) && (1.5 <= quux) && (foo < bar))", true)

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
      t(t9, "(!(foo > bar) && ((quux >= quux) && (quux > foo) && (1.5 <= quux) && (foo < bar)))", true)
      t(t10, "(!(quux > foo) || ((foo > bar) && (foo > foo)) || ((foo < bar) && (1.5 <= quux)))", true)

      t(f9, "(!(foo > bar) && ((quux >= quux) && (quux > foo) && (1.5 <= quux) && (foo < bar)) && !(quux > foo))", false)
      t(f10, "!((quux >= quux) && (quux > foo) && (1.5 <= quux) && (foo < bar))", false)
    end
  end

  context "Constant" do
    it "represents float 2.34" do
      t_num(e_const(2.34), "2.34", 2.34, {c: "Const", v: 2.34})
    end

    it "represents integer 234" do
      t_num(e_const(234), "234.0", 234, {c: "Const", v: 234})
    end
  end


  context "Lookup" do
    let(:ctx) { {foo: 2.34, bar: 5.67} }

    it "foo = 2.34" do
      t_num(e_lookup(:foo), "foo", 2.34, {c: "Lookup", v: "foo"})
    end

    it "bar = 5.67; handles string ids" do
      t_num(e_lookup("bar"), "bar", 5.67, {c: "Lookup", v: "bar"})
    end

    it "raises error for missing id" do
      e = e_lookup("quux")
      expect{e.eval(ctx)}.to raise_error("Missing value for id 'quux'")
    end
  end

  context "Add" do
    it "20" do
      t_num(e_add(e_const(20.0)), 
        "20.0",
        20.0, 
        {c: "Add", v: [
          {c: "Const", v: 20},
        ]})
    end

    it "20 + 2 + 3.5" do
      t_num(e_add(e_const(20.0), e_const(2.0), e_const(3.5)), 
        "(20.0 + 2.0 + 3.5)",
        25.5, 
        {c: "Add", v: [
          {c: "Const", v: 20},
          {c: "Const", v: 2},
          {c: "Const", v: 3.5},
        ]})
    end
  end

  context "Sub" do
    it "20 - 5" do
      t_num(e_sub(e_const(20.0), e_const(5.0)), 
        "(20.0 - 5.0)",
        15.0, 
        {c: "Sub", v: {l: {c: "Const", v: 20.0},  r: {c: "Const", v: 5.0}}})
    end
  end

  context "Mul" do
    it "20" do
      t_num(e_mul(e_const(20.0)), 
        "20.0",
        20.0, 
        {c: "Mul", v: [
          {c: "Const", v: 20},
        ]})
    end

    it "20 * 2 * 1.5" do
      t_num(e_mul(e_const(20.0), e_const(2.0), e_const(1.5)), 
        "(20.0 * 2.0 * 1.5)",
        60.0, 
        {c: "Mul", v: [
          {c: "Const", v: 20},
          {c: "Const", v: 2},
          {c: "Const", v: 1.5},
        ]})
    end
  end

  context "Div" do
    it "20 / 5" do
      t_num(e_div(e_const(20.0), e_const(5.0)), 
        "(20.0 / 5.0)",
        4.0, 
        {c: "Div", v: {l: {c: "Const", v: 20.0},  r: {c: "Const", v: 5.0}}})
    end
  end

  context "Pow" do
    it "20 ^ 2" do
      t_num(e_pow(e_const(20.0), e_const(2.0)), 
        "(20.0 ^ 2.0)",
        400.0, 
        {c: "Pow", v: {l: {c: "Const", v: 20.0},  r: {c: "Const", v: 2.0}}})
    end
  end

  context "Exceptions" do
    let(:ctx) { {
      foo: 1.0,
      bar: 2.0,
      quux: 2.0,
      str: "non numeric string",
      empty: nil
    } }

    def t_err(e, str_exp, exception_exp)
      expect(e.to_s).to eq(str_exp)
      expect{e.eval(ctx)}.to raise_error(exception_exp)
    end

    it "Missing Value" do
      t_err(e_lt(e_foo, e_lookup("xxx")), "(foo < xxx)", "Missing value for id 'xxx'")
    end

    it "Non-numeric Value" do
      t_err(e_lt(e_foo, e_str), "(foo < str)", "Value for expression 'str' is not numeric ('non numeric string')")
    end

    it "Non-numeric Value" do
      t_err(e_lt(e_foo, e_empty), "(foo < empty)", "Value for expression 'empty' is nil")
    end
  end

  context "Marshaling" do
    def t_marshal(expr, exp)
      act = expr.marshal
      expect(act).to eq(exp)

      expr_new = Expr::Base.unmarshal(act)
      expect(expr_new.to_s).to eq(expr.to_s)
    end

    it ".short_class_name" do
      expect(e_true.short_class_name).to eq("True")
      expect(e_gt(e_foo, e_foo).short_class_name).to eq("GT")
      expect(e_and(e_true).short_class_name).to eq("And")
    end

    it "#full_class_name" do
      expect(Expr::Base.full_class_name("And")).to eq("Expr::And")
    end

    it "True" do
      t_marshal(e_true, {c: "True"})
    end

    it "Not(True)" do
      t_marshal(e_not(e_true), {c: "Not", v: {c: "True"}})
    end

    it "And(True)" do
      t_marshal(e_and(e_true), {c: "And", v: [{c: "True"}]})
    end

    it "Or(True)" do
      t_marshal(e_or(e_true), {c: "Or", v: [{c: "True"}]})
    end

    it "And(Or(True, Not(True)), Or(True, True))" do
      exp = {c: "And", v: [
        {c: "Or", v: [{c: "True"}, {c: "Not", v: {c: "True"}}]},
        {c: "Or", v: [{c: "True"}, {c: "True"}]}]}
      t_marshal(e_and(e_or(e_true, e_not(e_true)), e_or(e_true, e_true)), exp)
    end

    it "NumCmp classes" do
      t_marshal(e_equal(e_foo, e_bar), {c: "Equal", v: {l: e_foo.marshal, r: e_bar.marshal}})
      t_marshal(e_lt(e_foo, e_bar), {c: "LT", v: {l: e_foo.marshal, r: e_bar.marshal}})
      t_marshal(e_lte(e_foo, e_bar), {c: "LTE", v: {l: e_foo.marshal, r: e_bar.marshal}})
      t_marshal(e_gt(e_bar, e_foo), {c: "GT", v: {l: e_bar.marshal, r: e_foo.marshal}})
      t_marshal(e_gte(e_bar, e_foo), {c: "GTE", v: {l: e_bar.marshal, r: e_foo.marshal}})
    end

    it "Combined logic & NumCmp" do
      expr = e_or(
        e_and(e_lt(e_foo, e_bar), e_lte(e_bar, e_quux)),
        e_and(e_gt(e_foo, e_bar), e_gte(e_foo, e_quux))
      )

      t_marshal(expr, {c: "Or", v: 
        [
          {c: "And", :v => [
            {c: "LT", :v => {l: e_foo.marshal, r: e_bar.marshal}}, 
            {c: "LTE", :v => {l: e_bar.marshal, r: e_quux.marshal}}]},
          {c: "And", :v => [
            {c: "GT", :v => {l: e_foo.marshal, r: e_bar.marshal}}, 
            {c: "GTE", :v => {l: e_foo.marshal, r: e_quux.marshal}}]}
        ]})
    end
  end
end