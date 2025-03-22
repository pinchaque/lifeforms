require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Const" do
  let(:ctx) { {} }

  context "float 5.67" do
    it_behaves_like "expr" do
      let(:expr) { e_const(5.67) }
      let(:eval_exp) { 5.67 }
      let(:str_exp) { "5.67" }
      let(:marshal_exp) { {c: "Const", v: 5.67} }
    end
  end

  context "integer 567" do
    it_behaves_like "expr" do
      let(:expr) { e_const(567) }
      let(:eval_exp) { 567 }
      let(:str_exp) { "567.0" }
      let(:marshal_exp) { {c: "Const", v: 567} }
    end
  end
end