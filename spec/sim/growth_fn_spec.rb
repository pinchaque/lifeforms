describe "GrowthFn" do
  let(:tol) { 0.0001 }
  let(:gf) { GrowthFn.new(exp, e_base) }
  let(:exp) { 1.0 }
  let(:e_base) { 1.0 }

  context "Linear" do
    let(:exp) { 1.0 }
    let(:e_base) { 1.0 }
  
    it "stasis" do
      [0, 1, 10, 100].each do |v|
        expect(gf.size_delta(v, v)).to be_within(tol).of(0.0)
      end
    end

    it "grows" do
      expect(gf.size_delta(0.0, 1.0)).to be_within(tol).of(1.0)
      expect(gf.size_delta(0.0, 4.0)).to be_within(tol).of(4.0)
      expect(gf.size_delta(10.0, 20.0)).to be_within(tol).of(10.0)
      expect(gf.size_delta(100.0, 400.0)).to be_within(tol).of(300.0)
    end

    it "shrinks" do
      expect(gf.size_delta(1.0, 0.0)).to be_within(tol).of(-1.0)
      expect(gf.size_delta(4.0, 0.0)).to be_within(tol).of(-4.0)
      expect(gf.size_delta(20.0, 10.0)).to be_within(tol).of(-10.0)
      expect(gf.size_delta(400.0, 100.0)).to be_within(tol).of(-300.0)
    end
  end

  context "Quadratic / base 1" do
    let(:exp) { 2.0 }
    let(:e_base) { 1.0 }
      
    it "stasis" do
      [0, 1, 10, 100].each do |v|
        expect(gf.size_delta(v, v)).to be_within(tol).of(0.0)
      end
    end

    it "grows" do
      expect(gf.size_delta(0.0, 1.0)).to be_within(tol).of(1.0)
      expect(gf.size_delta(0.0, 4.0)).to be_within(tol).of(2.0)
      expect(gf.size_delta(9.0, 25.0)).to be_within(tol).of(2.0)
      expect(gf.size_delta(100.0, 225.0)).to be_within(tol).of(5.0)
    end

    it "shrinks" do
      expect(gf.size_delta(1.0, 0.0)).to be_within(tol).of(-1.0)
      expect(gf.size_delta(4.0, 0.0)).to be_within(tol).of(-2.0)
      expect(gf.size_delta(25.0, 9.0)).to be_within(tol).of(-2.0)
      expect(gf.size_delta(225.0, 100.0)).to be_within(tol).of(-5.0)
    end
  end

  context "Quadratic / base 16" do
    let(:exp) { 2.0 }
    let(:e_base) { 16.0 }
      
    it "stasis" do
      [0, 1, 10, 100].each do |v|
        expect(gf.size_delta(v, v)).to be_within(tol).of(0.0)
      end
    end

    it "grows" do
      expect(gf.size_delta(0.0, 1.0)).to be_within(tol).of(0.25)
      expect(gf.size_delta(0.0, 4.0)).to be_within(tol).of(0.5)
      expect(gf.size_delta(9.0, 25.0)).to be_within(tol).of(0.5)
      expect(gf.size_delta(100.0, 225.0)).to be_within(tol).of(1.25)
    end

    it "shrinks" do
      expect(gf.size_delta(1.0, 0.0)).to be_within(tol).of(-0.25)
      expect(gf.size_delta(4.0, 0.0)).to be_within(tol).of(-0.5)
      expect(gf.size_delta(25.0, 9.0)).to be_within(tol).of(-0.5)
      expect(gf.size_delta(225.0, 100.0)).to be_within(tol).of(-1.25)
    end
  end

  context "Exceptions" do
    it "exponent 0" do
      expect{ GrowthFn.new(0.0, 1.0) }.to raise_error("exp (0.0) cannot be <= 0")
    end

    it "exponent < 0" do
      expect{ GrowthFn.new(-1.0, 1.0) }.to raise_error("exp (-1.0) cannot be <= 0")
    end

    it "base_energy < 0" do
      expect{ GrowthFn.new(1.0, -1.0) }.to raise_error("e_base (-1.0) cannot be < 0")
    end

    it "negative energy_start" do
      expect{gf.size_delta(-0.004, 4)}.to raise_error("energy_start (-0.004) cannot be < 0")
    end

    it "negative energy_end" do
      expect{gf.size_delta(0, -0.3)}.to raise_error("energy_end (-0.3) cannot be < 0")
    end
  end
end