require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Sub" do
  let(:ctx) { {} }

  context "20 - 5" do
    it_behaves_like "expr" do
      let(:expr) { e_sub(e_const(20.0), e_const(5.0)) }
      let(:eval_exp) { 15.0 }
      let(:str_exp) { "(20.0 - 5.0)" }
      let(:marshal_exp) { {c: "Sub", v: {l: {c: "Const", v: 20.0},  r: {c: "Const", v: 5.0}}}}
    end
  end
end