RSpec.shared_examples "expr_numeric" do
  it ".eval" do
    ctx = {} unless defined?(ctx)
    expect(expr.eval(ctx)).to be_within(0.0001).of(eval_exp)
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