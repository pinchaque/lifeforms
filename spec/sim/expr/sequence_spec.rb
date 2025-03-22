require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Sequence" do
  let(:tol) { 0.0001 }
  let(:ctx) { {} }

  context "single" do
    it_behaves_like "expr" do
      let(:expr) { e_seq(e_const(2.34)) }
      let(:eval_exp) { 2.34 }
      let(:str_exp) { "2.34" }
      let(:marshal_exp) { {c: "Sequence", v: [
        {c: "Const", v: 2.34},
      ] } }
    end
  end

  context "multiple returns final value" do
    it_behaves_like "expr" do
      let(:expr) { e_seq(e_const(2.34), e_const(5.67), e_const(8.91)) }
      let(:eval_exp) { 8.91 }
      let(:str_exp) { "(2.34 -> 5.67 -> 8.91)" }
      let(:marshal_exp) { {c: "Sequence", v: [
        {c: "Const", v: 2.34},
        {c: "Const", v: 5.67},
        {c: "Const", v: 8.91},
      ] } }
    end
  end

  context "actually executes all Exprs" do

    # mock skill class that simply increments lifeform size by one and returns
    # the new size
    class TestGenInc < Skill::Base
      def self.eval(ctx)
        ctx.lifeform.size += 1.0
      end
    end

    let(:lf) { 
      l = MockLifeform.new 
      l.size = 0
      l.register_skill(TestGenInc)
      l
    }
    let(:ctx) { Context.new(lf) }

    context "one expr" do
      let(:expr) { e_seq(e_skill(:test_gen_inc)) }
    
      it "executes all exprs in sequence" do
        result = expr.eval(ctx)
        expect(result).to be_within(tol).of(1)
        expect(lf.size).to be_within(tol).of(1)
      end
    end

    context "three exprs" do
      let(:expr) { e_seq(e_skill(:test_gen_inc), e_skill(:test_gen_inc), e_skill(:test_gen_inc)) }
    
      it "executes all exprs in sequence" do
        result = expr.eval(ctx)
        expect(result).to be_within(tol).of(3)
        expect(lf.size).to be_within(tol).of(3)
      end
    end
  end
end