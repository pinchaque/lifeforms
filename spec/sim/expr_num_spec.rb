describe "ExprNum" do
  let(:tol) { 0.0001 }
  let(:ctx) { {} }

  def t(expr, str_exp, eval_exp, marshal_exp)
    expect(expr.to_s).to eq(str_exp)
    expect(expr.eval(ctx)).to be_within(tol).of(eval_exp)
    expect(expr.marshal).to eq(marshal_exp)
  end

  context "Constant" do
    it "represents float 2.34" do
      t(e_const(2.34), "2.34", 2.34, {t: "Const", v: 2.34})
    end

    it "represents integer 234" do
      t(e_const(234), "234", 234, {t: "Const", v: 234})
    end
  end


  context "Lookup" do
    let(:ctx) { {foo: 2.34, bar: 5.67} }

    it "foo = 2.34" do
      t(e_lookup(:foo), "foo", 2.34, {t: "Lookup", v: "foo"})
    end

    it "bar = 5.67; handles string ids" do
      t(e_lookup("bar"), "bar", 5.67, {t: "Lookup", v: "bar"})
    end

    it "raises error for missing id" do
      e = e_lookup("quux")
      expect{e.eval(ctx)}.to raise_error("Missing value for id 'quux'")
    end
  end

  context "Add" do
    it "20" do
      t(e_add(e_const(20.0)), 
        "20.0",
        20.0, 
        {t: "Add", v: [
          {t: "Const", v: 20},
        ]})
    end

    it "20 + 2 + 3.5" do
      t(e_add(e_const(20.0), e_const(2.0), e_const(3.5)), 
        "(20.0 + 2.0 + 3.5)",
        25.5, 
        {t: "Add", v: [
          {t: "Const", v: 20},
          {t: "Const", v: 2},
          {t: "Const", v: 3.5},
        ]})
    end
  end

  context "Sub" do
    it "20 - 5" do
      t(e_sub(e_const(20.0), e_const(5.0)), 
        "(20.0 - 5.0)",
        15.0, 
        {t: "Sub", v: {l: {t: "Const", v: 20.0},  r: {t: "Const", v: 5.0}}})
    end
  end

  context "Mul" do
    it "20" do
      t(e_mul(e_const(20.0)), 
        "20.0",
        20.0, 
        {t: "Mul", v: [
          {t: "Const", v: 20},
        ]})
    end

    it "20 * 2 * 1.5" do
      t(e_mul(e_const(20.0), e_const(2.0), e_const(1.5)), 
        "(20.0 * 2.0 * 1.5)",
        60.0, 
        {t: "Mul", v: [
          {t: "Const", v: 20},
          {t: "Const", v: 2},
          {t: "Const", v: 1.5},
        ]})
    end
  end

  context "Div" do
    it "20 / 5" do
      t(e_div(e_const(20.0), e_const(5.0)), 
        "(20.0 / 5.0)",
        4.0, 
        {t: "Div", v: {l: {t: "Const", v: 20.0},  r: {t: "Const", v: 5.0}}})
    end
  end

  context "Pow" do
    it "20 ^ 2" do
      t(e_pow(e_const(20.0), e_const(2.0)), 
        "(20.0 ^ 2.0)",
        400.0, 
        {t: "Pow", v: {l: {t: "Const", v: 20.0},  r: {t: "Const", v: 2.0}}})
    end
  end

  context "Marshaling" do
    def t_marshal(expr, exp)
      act = expr.marshal
      expect(act).to eq(exp)

      expr_new = ExprNum::Base.unmarshal(act)
      expect(expr_new.to_s).to eq(expr.to_s)
    end

    it ".short_class_name" do
      expect(e_const(2.34).short_class_name).to eq("Const")
    end

    it "#full_class_name" do
      expect(ExprNum::Base.full_class_name("Const")).to eq("ExprNum::Const")
    end

    it "Const" do
      t_marshal(e_const(2.34), {t: "Const", v: 2.34})
    end
  end
end