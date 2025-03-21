require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::And" do
  context "And(True)" do
    it_behaves_like "expr" do
      let(:expr) { e_and(e_true) }
      let(:eval_exp) { true }
      let(:str_exp) { "true" }
      let(:marshal_exp) { {c: "And", v: [
        {c: "True"},
      ]} }
    end
  end

  context "And(True, True, True)" do
    it_behaves_like "expr" do
      let(:expr) { e_and(e_true, e_true, e_true) }
      let(:eval_exp) { true }
      let(:str_exp) { "(true && true && true)" }
      let(:marshal_exp) { {c: "And", v: [
        {c: "True"},
        {c: "True"},
        {c: "True"},
      ]} }
    end
  end


  context "And(True, True, False)" do
    it_behaves_like "expr" do
      let(:expr) { e_and(e_true, e_true, e_false) }
      let(:eval_exp) { false }
      let(:str_exp) { "(true && true && false)" }
      let(:marshal_exp) { {c: "And", v: [
        {c: "True"},
        {c: "True"},
        {c: "False"},
      ]} }
    end
  end
end