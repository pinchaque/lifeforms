include Program

describe "Expr" do
  let(:tol) { 0.0001 }
  let(:h) { {} }

  context "Logic Basics" do
    it "Returns True" do
      e = e_true
      expect(e.to_s).to eq("true")
      expect(e.eval(h)).to be true
    end

    it "Not(True)" do
      e = e_not(e_true)
      expect(e.to_s).to eq("!true")
      expect(e.eval(h)).to be false
    end

    it "And(True)" do
      e = e_and(e_true)
      expect(e.to_s).to eq("true")
      expect(e.eval(h)).to be true
    end

    it "And(Not(True))" do
      e = e_and(e_not(e_true))
      expect(e.to_s).to eq("!true")
      expect(e.eval(h)).to be false
    end

    it "And(True, True, True)" do
      e = e_and(e_true, e_true, e_true)
      expect(e.to_s).to eq("(true && true && true)")
      expect(e.eval(h)).to be true
    end

    it "And(True, False, True)" do
      e = e_and(e_true, e_not(e_true), e_true)
      expect(e.to_s).to eq("(true && !true && true)")
      expect(e.eval(h)).to be false
    end

    it "And(False, False, False)" do
      e = e_and(e_not(e_true), e_not(e_true), e_not(e_true))
      expect(e.to_s).to eq("(!true && !true && !true)")
      expect(e.eval(h)).to be false
    end

    it "Or(True)" do
      e = e_or(e_true)
      expect(e.to_s).to eq("true")
      expect(e.eval(h)).to be true
    end

    it "Or(Not(True))" do
      e = e_or(e_not(e_true))
      expect(e.to_s).to eq("!true")
      expect(e.eval(h)).to be false
    end

    it "Or(True, True, True)" do
      e = e_or(e_true, e_true, e_true)
      expect(e.to_s).to eq("(true || true || true)")
      expect(e.eval(h)).to be true
    end

    it "Or(True, False, True)" do
      e = e_or(e_true, e_not(e_true), e_true)
      expect(e.to_s).to eq("(true || !true || true)")
      expect(e.eval(h)).to be true
    end

    it "Or(False, False, False)" do
      e = e_or(e_not(e_true), e_not(e_true), e_not(e_true))
      expect(e.to_s).to eq("(!true || !true || !true)")
      expect(e.eval(h)).to be false
    end
  end

  context "Nested Logic" do
    it "And(Or(False, True), Or(True, True))" do
      e = e_and(e_or(e_not(e_true), e_true), e_or(e_true, e_true)) 
      expect(e.to_s).to eq("((!true || true) && (true || true))")
      expect(e.eval(h)).to be true
    end

    it "Or(And(False, True), And(True, True))" do
      e = e_or(e_and(e_not(e_true), e_true), e_and(e_true, e_true)) 
      expect(e.to_s).to eq("((!true && true) || (true && true))")
      expect(e.eval(h)).to be true
    end

    it "Or(And(False, True), And(True, False))" do
      e = e_or(e_and(e_not(e_true), e_true), e_and(e_true, e_not(e_true))) 
      expect(e.to_s).to eq("((!true && true) || (true && !true))")
      expect(e.eval(h)).to be false
    end
  end
  
  context "Numeric Cmp" do
    let(:h) { {
      foo: 1.0,
      bar: 2.0,
      quux: 2.0 
    } }

    def t(expr, str_exp, eval_exp)
      expect(expr.to_s).to eq(str_exp)
      expect(expr.eval(h)).to be eval_exp      
    end

    it "Equal" do
      t(e_equal(:foo, :foo), "foo == foo", true)
      t(e_equal(:bar, :quux), "bar == quux", true)
      t(e_equal(:foo, :bar), "foo == bar", false)
    end

    it "Less Than" do
      t(e_lt(:foo, :foo), "foo < foo", false)
      t(e_lt(:bar, :quux), "bar < quux", false)
      t(e_lt(:quux, :bar), "quux < bar", false)
      t(e_lt(:foo, :bar), "foo < bar", true)
      t(e_lt(:bar, :foo), "bar < foo", false)
    end

    it "Less Than Equal" do
      t(e_lte(:foo, :foo), "foo <= foo", true)
      t(e_lte(:bar, :quux), "bar <= quux", true)
      t(e_lte(:quux, :bar), "quux <= bar", true)
      t(e_lte(:foo, :bar), "foo <= bar", true)
      t(e_lte(:bar, :foo), "bar <= foo", false)
    end

    it "Greater Than" do
      t(e_gt(:foo, :foo), "foo > foo", false)
      t(e_gt(:bar, :quux), "bar > quux", false)
      t(e_gt(:quux, :bar), "quux > bar", false)
      t(e_gt(:foo, :bar), "foo > bar", false)
      t(e_gt(:bar, :foo), "bar > foo", true)
    end

    it "Greater Than Equal" do
      t(e_gte(:foo, :foo), "foo >= foo", true)
      t(e_gte(:bar, :quux), "bar >= quux", true)
      t(e_gte(:quux, :bar), "quux >= bar", true)
      t(e_gte(:foo, :bar), "foo >= bar", false)
      t(e_gte(:bar, :foo), "bar >= foo", true)
    end
  end
end