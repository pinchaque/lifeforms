RSpec.shared_examples "expr" do
  it ".eval" do
    if eval_exp == true
      expect(expr.eval(ctx)).to be true
    elsif eval_exp == false
      expect(expr.eval(ctx)).to be false
    else
      expect(expr.eval(ctx)).to be_within(0.0001).of(eval_exp)
    end
  end

  it ".to_s" do
    expect(expr.to_s).to eq(str_exp) if defined?(str_exp)
  end

  it ".marshal" do
    expect(expr.marshal).to eq(marshal_exp) if defined?(marshal_exp)
  end

  it "#unmarshal" do
    act = expr.marshal
    expr_new = Expr::Base.unmarshal(act)
    expect(expr_new.to_s).to eq(expr.to_s)
    expect(expr_new.class).to eq(expr.class)
  end
end