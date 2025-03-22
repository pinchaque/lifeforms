require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Add" do
  let(:ctx) { {} }
  context "20 + 2 + 3.5" do
    it_behaves_like "expr" do
      let(:expr) { e_add(e_const(20.0), e_const(2.0), e_const(3.5)) }
      let(:eval_exp) { 25.5 }
      let(:str_exp) { "(20.0 + 2.0 + 3.5)" }
      let(:marshal_exp) { {c: "Add", v: [
        {c: "Const", v: 20},
        {c: "Const", v: 2},
        {c: "Const", v: 3.5},
      ]} }
    end
  end

  context "20" do
    it_behaves_like "expr" do
      let(:expr) { e_add(e_const(20.0)) }
      let(:eval_exp) { 20.0 }
      let(:str_exp) { "20.0" }
      let(:marshal_exp) { {c: "Add", v: [
        {c: "Const", v: 20},
      ]} }
    end
  end
end