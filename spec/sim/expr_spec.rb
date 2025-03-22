require File.dirname(__FILE__) + '/expr/test_helper.rb'

# Integation tests of more complex expressions
describe "Expr Integration" do
  let(:ctx) { {} }
  context "Numeric" do
    context "((2.0 + 15.0 + 3.0) / (7.0 - 3.0))" do
      it_behaves_like "expr" do
        let(:expr) { e_div(e_add(e_const(2.0), e_const(15.0), e_const(3.0)), e_sub(e_const(7), e_const(3))) }
        let(:eval_exp) { 5.0 }
        let(:str_exp) { "((2.0 + 15.0 + 3.0) / (7.0 - 3.0))" }
        let(:marshal_exp) { {c: "Div", v: {
          l: {c: "Add", v: [
            {c: "Const", v: 2.0},
            {c: "Const", v: 15.0},
            {c: "Const", v: 3.0},
          ]},
          r: {c: "Sub", v: {
            l: {c: "Const", v: 7.0},
            r: {c: "Const", v: 3.0},
        }}}}}
      end
    end

    context "(2 ^ (3 * 4))" do
      it_behaves_like "expr" do
        let(:expr) { e_pow(e_const(2), e_mul(e_const(3), e_const(4))) }
        let(:eval_exp) { 4096 }
        let(:str_exp) { "(2.0 ^ (3.0 * 4.0))" }
        let(:marshal_exp) { {c: "Pow", v: {
          l: {c: "Const", v: 2.0},
          r: {c: "Mul", v: [
            {c: "Const", v: 3.0},
            {c: "Const", v: 4.0},
        ]}}}}
      end
    end
  end

  context "Boolean" do
    let(:t1) { e_lt(e_const(5.1), e_const(11.9)) }
    let(:t2) { e_equal(e_const(11.0), e_add(e_const(1.0), e_const(10.0))) }
    let(:f1) { e_gte(e_pow(e_const(2.0), e_const(3.0)), e_sub(e_const(12.0), e_const(3.0))) }
    let(:f2) { e_lte(e_div(e_const(8.0), e_const(3.0)), e_const(2.5)) }

    context "t1" do
      it_behaves_like "expr" do
        let(:expr) { t1 }
        let(:eval_exp) { true }
        let(:str_exp) { "(5.1 < 11.9)" }
      end
    end

    context "t2" do
      it_behaves_like "expr" do
        let(:expr) { t2 }
        let(:eval_exp) { true }
        let(:str_exp) { "(11.0 == (1.0 + 10.0))" }
      end
    end

    context "f1" do
      it_behaves_like "expr" do
        let(:expr) { f1 }
        let(:eval_exp) { false }
        let(:str_exp) { "((2.0 ^ 3.0) >= (12.0 - 3.0))" }
      end
    end
    context "f2" do
      it_behaves_like "expr" do
        let(:expr) { f2 }
        let(:eval_exp) { false }
        let(:str_exp) { "((8.0 / 3.0) <= 2.5)" }
      end
    end

    context "(t1 && !f1) || (f2 && t2)" do
      it_behaves_like "expr" do
        let(:expr) { e_or(
          e_and(t1, e_not(f1)),
          e_and(f2, t2)
        ) }
        let(:eval_exp) { true }
      end
    end

    context "(t1 && f1) || (f2 && t2)" do
      it_behaves_like "expr" do
        let(:expr) { e_or(
          e_and(t1, f1),
          e_and(f2, t2)
        ) }
        let(:eval_exp) { false }
      end
    end

    context "(!t1 || !f1) && (f2 || t2)" do
      it_behaves_like "expr" do
        let(:expr) { e_and(
          e_or(e_not(t1), e_not(f1)),
          e_or(f2, t2)
        ) }
        let(:eval_exp) { true }
      end
    end

    context "(!t1 || f1) && (f2 || t2)" do
      it_behaves_like "expr" do
        let(:expr) { e_and(
          e_or(e_not(t1), f1),
          e_or(f2, t2)
        ) }
        let(:eval_exp) { false }
      end
    end
  end

  context "Statements" do
    let(:t1) { e_lt(e_const(5.1), e_const(11.9)) }
    let(:t2) { e_equal(e_const(11.0), e_add(e_const(1.0), e_const(10.0))) }
    let(:f1) { e_gte(e_pow(e_const(2.0), e_const(3.0)), e_sub(e_const(12.0), e_const(3.0))) }
    let(:f2) { e_lte(e_div(e_const(8.0), e_const(3.0)), e_const(2.5)) }

    context "If inside Seq" do
      let(:if1) { e_if(t1, e_const(1.23), e_const(4.56)) }
      let(:if2) { e_if(f1, e_const(7.89), e_const(0.12)) }
  
      context "seq(if1, if2)" do
        it_behaves_like "expr" do
          let(:expr) { e_seq(if1, if2) }
          let(:eval_exp) { 0.12 }
        end
      end

      context "seq(if2, if1)" do
        it_behaves_like "expr" do
          let(:expr) { e_seq(if2, if1) }
          let(:eval_exp) { 1.23 }
        end
      end
    end

    context "Seq inside If" do
      let(:seq1) { e_seq(e_const(1.23), e_const(4.56)) }
      let(:seq2) { e_seq(e_const(7.89), e_const(0.12)) }

      context "if(true, seq1, seq2)" do
        it_behaves_like "expr" do
          let(:expr) { e_if(e_true, seq1, seq2) }
          let(:eval_exp) { 4.56 }
        end
      end
      context "if(false, seq1, seq2)" do
        it_behaves_like "expr" do
          let(:expr) { e_if(e_false, seq1, seq2) }
          let(:eval_exp) { 0.12 }
        end
      end
    end
  end
end