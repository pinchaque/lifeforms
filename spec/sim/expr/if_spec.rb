require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::If" do
  let(:ctx) { {} }

  context "true branch" do
    it_behaves_like "expr" do
      let(:expr) { e_if(e_true, e_const(2.34), e_const(5.67)) }
      let(:eval_exp) { 2.34 }
      let(:str_exp) { "(IF true THEN 2.34 ELSE 5.67)" }
      let(:marshal_exp) { {c: "If", v: {
        if: {c: "True"},
        then: {c: "Const", v: 2.34},
        else: {c: "Const", v: 5.67}
      } } }
    end
  end

  context "false branch" do
    it_behaves_like "expr" do
      let(:expr) { e_if(e_false, e_const(2.34), e_const(5.67)) }
      let(:eval_exp) { 5.67 }
      let(:str_exp) { "(IF false THEN 2.34 ELSE 5.67)" }
      let(:marshal_exp) { {c: "If", v: {
        if: {c: "False"},
        then: {c: "Const", v: 2.34},
        else: {c: "Const", v: 5.67}
      } } }
    end
  end

  context "true without else" do
    it_behaves_like "expr" do
      let(:expr) { e_if(e_true, e_const(2.34)) }
      let(:eval_exp) { 2.34 }
      let(:str_exp) { "(IF true THEN 2.34 ELSE false)" }
      let(:marshal_exp) { {c: "If", v: {
        if: {c: "True"},
        then: {c: "Const", v: 2.34},
        else: {c: "False"}
      } } }
    end 
  end

  context "false without else" do
    it_behaves_like "expr" do
      let(:expr) { e_if(e_false, e_const(2.34)) }
      let(:eval_exp) { false }
      let(:str_exp) { "(IF false THEN 2.34 ELSE false)" }
      let(:marshal_exp) { {c: "If", v: {
        if: {c: "False"},
        then: {c: "Const", v: 2.34},
        else: {c: "False"}
      } } }
    end 
  end
end