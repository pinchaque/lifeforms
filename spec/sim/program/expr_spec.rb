include Program

describe "Expr" do
  let(:tol) { 0.0001 }
  let(:h) { {} }

  context "Logic Basics" do
    it "Returns True" do
      e = e_true
      expect(e.to_s).to eq("true")
      expect(e.eval(h)).to be true
    end

    it "Not(True)" do
      e = e_not(e_true)
      expect(e.to_s).to eq("!true")
      expect(e.eval(h)).to be false
    end

    it "And(True)" do
      e = e_and(e_true)
      expect(e.to_s).to eq("true")
      expect(e.eval(h)).to be true
    end

    it "And(Not(True))" do
      e = e_and(e_not(e_true))
      expect(e.to_s).to eq("!true")
      expect(e.eval(h)).to be false
    end

    it "And(True, True, True)" do
      e = e_and(e_true, e_true, e_true)
      expect(e.to_s).to eq("(true && true && true)")
      expect(e.eval(h)).to be true
    end

    it "And(True, False, True)" do
      e = e_and(e_true, e_not(e_true), e_true)
      expect(e.to_s).to eq("(true && !true && true)")
      expect(e.eval(h)).to be false
    end

    it "And(False, False, False)" do
      e = e_and(e_not(e_true), e_not(e_true), e_not(e_true))
      expect(e.to_s).to eq("(!true && !true && !true)")
      expect(e.eval(h)).to be false
    end

    it "Or(True)" do
      e = e_or(e_true)
      expect(e.to_s).to eq("true")
      expect(e.eval(h)).to be true
    end

    it "Or(Not(True))" do
      e = e_or(e_not(e_true))
      expect(e.to_s).to eq("!true")
      expect(e.eval(h)).to be false
    end

    it "Or(True, True, True)" do
      e = e_or(e_true, e_true, e_true)
      expect(e.to_s).to eq("(true || true || true)")
      expect(e.eval(h)).to be true
    end

    it "Or(True, False, True)" do
      e = e_or(e_true, e_not(e_true), e_true)
      expect(e.to_s).to eq("(true || !true || true)")
      expect(e.eval(h)).to be true
    end

    it "Or(False, False, False)" do
      e = e_or(e_not(e_true), e_not(e_true), e_not(e_true))
      expect(e.to_s).to eq("(!true || !true || !true)")
      expect(e.eval(h)).to be false
    end
  end

  context "Nested Logic" do
    it "And(Or(False, True), Or(True, True))" do
      e = e_and(e_or(e_not(e_true), e_true), e_or(e_true, e_true)) 
      expect(e.to_s).to eq("((!true || true) && (true || true))")
      expect(e.eval(h)).to be true
    end

    it "Or(And(False, True), And(True, True))" do
      e = e_or(e_and(e_not(e_true), e_true), e_and(e_true, e_true)) 
      expect(e.to_s).to eq("((!true && true) || (true && true))")
      expect(e.eval(h)).to be true
    end

    it "Or(And(False, True), And(True, False))" do
      e = e_or(e_and(e_not(e_true), e_true), e_and(e_true, e_not(e_true))) 
      expect(e.to_s).to eq("((!true && true) || (true && !true))")
      expect(e.eval(h)).to be false
    end
  end
end