require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::True" do
  let(:ctx) { {} }

  context "true" do
    it_behaves_like "expr" do
      let(:expr) { e_true }
      let(:eval_exp) { true }
      let(:str_exp) { "true" }
      let(:marshal_exp) { {c: "True"} }
    end
  end
end