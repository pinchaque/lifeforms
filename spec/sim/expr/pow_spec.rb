require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Pow" do
  let(:ctx) { {} }

  context "20 ^ 2" do
    it_behaves_like "expr" do
      let(:expr) { e_pow(e_const(20.0), e_const(2.0)) }
      let(:eval_exp) { 400.0 }
      let(:str_exp) { "(20.0 ^ 2.0)" }
      let(:marshal_exp) { {c: "Pow", v: {l: {c: "Const", v: 20.0},  r: {c: "Const", v: 2.0}}}}
    end
  end
end