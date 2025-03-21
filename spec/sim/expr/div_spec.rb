require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Div" do
  let(:ctx) { {} }

  context "20 / 5" do
    it_behaves_like "expr" do
      let(:expr) { e_div(e_const(20.0), e_const(5.0)) }
      let(:eval_exp) { 4.0 }
      let(:str_exp) { "(20.0 / 5.0)" }
      let(:marshal_exp) { {c: "Div", v: {l: {c: "Const", v: 20.0},  r: {c: "Const", v: 5.0}}}}
    end
  end
end