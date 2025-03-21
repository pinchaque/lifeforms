
def t_num(expr, eval_exp, str_exp = nil, marshal_exp = nil)
  expect(expr.eval(ctx)).to be_within(tol).of(eval_exp)
  unless str_exp.nil?
    expect(expr.to_s).to eq(str_exp)
  end
  unless marshal_exp.nil?
    expect(expr.marshal).to eq(marshal_exp)
  end
end