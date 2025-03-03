include Program::Expr

describe "Expr" do
  let(:tol) { 0.0001 }
  let(:h) { {} }

  context "True" do
    it "Returns True" do
      e = True.new
      expect(e.to_s).to eq("true")
      expect(e.eval(h)).to be true
    end
  end

  context "Not(True)" do
    it "Returns False" do
      e = Not.new(True.new)
      expect(e.to_s).to eq("!(true)")
      expect(e.eval(h)).to be false
    end
  end
end