describe "ExprNum" do
  let(:tol) { 0.0001 }
  let(:ctx) { {} }

  def t(expr, str_exp, eval_exp)
    expect(expr.to_s).to eq(str_exp)
    expect(expr.eval(ctx)).to be_within(tol).of(eval_exp)
  end

  context "Constant" do
    it "represents float 2.34" do
      t(e_const(2.34), "2.34", 2.34)
    end

    it "represents integer 234" do
      t(e_const(2.34), "2.34", 2.34)
    end
  end
end