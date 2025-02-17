describe "GrowthFn" do
  let(:tol) { 0.0001 }
  let(:gf) { GrowthFn.new(scale) }
  let(:scale) { 1.0 }

  context "Linear" do
    let(:scale) { 1.0 }

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

  context "Quadratic" do
    let(:scale) { 2.0 }
    
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

  context "Exceptions" do
    it "scale factor 0" do
      expect{ GrowthFn.new(0.0) }.to raise_error("scale_factor cannot be 0")
    end

    it "negative energy_start" do
      expect{gf.size_delta(-0.004, 4)}.to raise_error("energy_start (-0.004) cannot be < 0")
    end

    it "negative energy_end" do
      expect{gf.size_delta(0, -0.3)}.to raise_error("energy_end (-0.3) cannot be < 0")
    end
  end
end