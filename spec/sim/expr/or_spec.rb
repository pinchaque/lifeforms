require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Or" do
  let(:ctx) { {} }
  
  context "Or(True)" do
    it_behaves_like "expr" do
      let(:expr) { e_or(e_true) }
      let(:eval_exp) { true }
      let(:str_exp) { "true" }
      let(:marshal_exp) { {c: "Or", v: [
        {c: "True"},
      ]} }
    end
  end

  context "Or(True, True, True)" do
    it_behaves_like "expr" do
      let(:expr) { e_or(e_true, e_true, e_true) }
      let(:eval_exp) { true }
      let(:str_exp) { "(true || true || true)" }
      let(:marshal_exp) { {c: "Or", v: [
        {c: "True"},
        {c: "True"},
        {c: "True"},
      ]} }
    end
  end

  context "Or(False, False)" do
    it_behaves_like "expr" do
      let(:expr) { e_or(e_false, e_false) }
      let(:eval_exp) { false }
      let(:str_exp) { "(false || false)" }
      let(:marshal_exp) { {c: "Or", v: [
        {c: "False"},
        {c: "False"},
      ]} }
    end
  end

  context "Or(True, True, False)" do
    it_behaves_like "expr" do
      let(:expr) { e_or(e_true, e_true, e_false) }
      let(:eval_exp) { true }
      let(:str_exp) { "(true || true || false)" }
      let(:marshal_exp) { {c: "Or", v: [
        {c: "True"},
        {c: "True"},
        {c: "False"},
      ]} }
    end
  end
end