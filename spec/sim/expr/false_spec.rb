require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::False" do
  let(:ctx) { {} }

  context "false" do
    it_behaves_like "expr" do
      let(:expr) { e_false }
      let(:eval_exp) { false }
      let(:str_exp) { "false" }
      let(:marshal_exp) { {c: "False"} }
    end
  end
end