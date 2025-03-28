require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::GT" do
  let(:ctx) { {} }

  context "2.34 > 2.34" do
    it_behaves_like "expr" do
      let(:expr) { e_gt(e_const(2.34), e_const(2.34)) }
      let(:eval_exp) { false }
      let(:str_exp) { "(2.34 > 2.34)" }
      let(:marshal_exp) { {c: "GT", v: {l: {c: "Const", v: 2.34},  r: {c: "Const", v: 2.34}}}}
    end
  end

  context "2.34 > 5.67" do
    it_behaves_like "expr" do
      let(:expr) { e_gt(e_const(2.34), e_const(5.67)) }
      let(:eval_exp) { false }
      let(:str_exp) { "(2.34 > 5.67)" }
      let(:marshal_exp) { {c: "GT", v: {l: {c: "Const", v: 2.34},  r: {c: "Const", v: 5.67}}}}
    end
  end

  context "5.67 > 2.34" do
    it_behaves_like "expr" do
      let(:expr) { e_gt(e_const(5.67), e_const(2.34)) }
      let(:eval_exp) { true }
      let(:str_exp) { "(5.67 > 2.34)" }
      let(:marshal_exp) { {c: "GT", v: {l: {c: "Const", v: 5.67},  r: {c: "Const", v: 2.34}}}}
    end
  end
end