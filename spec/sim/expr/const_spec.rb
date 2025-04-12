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

  context ".mutate_real" do
    it "produces different positive value" do
      v1 = 5.12
      expr = e_const(v1)
      expr.mutate_real(ctx)
      expect(expr.value).not_to eq(v1)
      expect(expr.value).to be >= 0.0
    end

    it "produces different negative value" do
      v1 = -5.12
      expr = e_const(v1)
      expr.mutate_real(ctx)
      expect(expr.value).not_to eq(v1)
      expect(expr.value).to be <= 0.0
    end
  end
end