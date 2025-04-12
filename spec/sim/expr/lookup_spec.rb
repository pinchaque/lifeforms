require File.dirname(__FILE__) + '/test_helper.rb'

describe "Expr::Lookup" do
  let(:ctx) { {foo: 2.34, bar: 5.67} }

  context "foo => 2.34" do
    it_behaves_like "expr" do
      let(:expr) { e_lookup(:foo) }
      let(:eval_exp) { 2.34 }
      let(:str_exp) { "foo" }
      let(:marshal_exp) { {c: "Lookup", v: "foo" } }
    end
  end

  context "bar => 5.67; handles string ids" do
    it_behaves_like "expr" do
      let(:expr) { e_lookup("bar") }
      let(:eval_exp) { 5.67 }
      let(:str_exp) { "bar" }
      let(:marshal_exp) { {c: "Lookup", v: "bar" } }
    end
  end

  context "quux => missing" do
    it "raises error for missing id" do
      e = e_lookup("quux")
      expect{e.eval(ctx)}.to raise_error("Missing value for id 'quux'")
    end
  end

  context ".mutate_real" do
    context "several keys to choose from" do
      let(:ctx) { {foo: 2.34, bar: 5.67, quux: 8.90} }
      it "uses different id" do
        id1 = :bar
        expr = e_lookup(id1)
        expr.mutate_real(ctx)
        expect(expr.id).not_to eq(id1)
      end
    end

    context "only one key" do
      let(:ctx) { {foo: 2.34} }
      it "changes nothing" do
        id1 = :foo
        expr = e_lookup(id1)
        expr.mutate_real(ctx)
        expect(expr.id).to eq(id1)
      end
    end
  end
end