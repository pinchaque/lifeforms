require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Mul" do
  let(:ctx) { {} }
  context "20 * 2 * 1.5" do
    it_behaves_like "expr" do
      let(:expr) { e_mul(e_const(20.0), e_const(2.0), e_const(1.5)) }
      let(:eval_exp) { 60.0 }
      let(:str_exp) { "(20.0 * 2.0 * 1.5)" }
      let(:marshal_exp) { {c: "Mul", v: [
        {c: "Const", v: 20},
        {c: "Const", v: 2},
        {c: "Const", v: 1.5},
      ]} }
    end
  end

  context "20" do
    it_behaves_like "expr" do
      let(:expr) { e_mul(e_const(20.0)) }
      let(:eval_exp) { 20.0 }
      let(:str_exp) { "20.0" }
      let(:marshal_exp) { {c: "Mul", v: [
        {c: "Const", v: 20},
      ]} }
    end
  end
end