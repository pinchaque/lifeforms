require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Not" do
  let(:ctx) { {} }
  
  context "Not(True)" do
    it_behaves_like "expr" do
      let(:expr) { e_not(e_true) }
      let(:eval_exp) { false }
      let(:str_exp) { "!true" }
      let(:marshal_exp) { {c: "Not", v: {c: "True"}} }
    end
  end

  context "Not(False)" do
    it_behaves_like "expr" do
      let(:expr) { e_not(e_false) }
      let(:eval_exp) { true }
      let(:str_exp) { "!false" }
      let(:marshal_exp) { {c: "Not", v: {c: "False"}} }
    end
  end
  
  context "Not(Not(True))" do
    it_behaves_like "expr" do
      let(:expr) { e_not(e_not(e_true)) }
      let(:eval_exp) { true }
      let(:str_exp) { "!!true" }
      let(:marshal_exp) { {c: "Not", v: {c: "Not", v: {c: "True"}}}}
    end
  end
end