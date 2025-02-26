describe "EnergyFn" do
  let(:tol) { 0.0001 }
  let(:ef) { EnergyFn.new(exp, e_base) }
  let(:exp) { 1.0 }
  let(:e_base) { 1.0 }

  context "Linear" do
    let(:exp) { 1.0 }
    let(:e_base) { 2.0 }

    [
      [0.0, 0.0],
      [1.0, 2.0],
      [2.0, 4.0],
      [10.0, 20.0],
    ].each do |a|
      size = a[0]
      egy = a[1]  
      it "energy/size round trip size:#{size} egy:#{egy}" do
        expect(ef.energy(size)).to be_within(tol).of(egy)
        expect(ef.size(egy)).to be_within(tol).of(size)
      end
    end
  end

  context "Quadratic / base 1" do
    let(:exp) { 2.0 }
    let(:e_base) { 1.0 }
    [
      [0.0, 0.0],
      [1.0, 1.0],
      [2.0, 4.0],
      [10.0, 100.0],
    ].each do |a|
      size = a[0]
      egy = a[1]  
      it "energy/size round trip size:#{size} egy:#{egy}" do
        expect(ef.energy(size)).to be_within(tol).of(egy)
        expect(ef.size(egy)).to be_within(tol).of(size)
      end
    end
  end

  context "Quadratic / base 16" do
    let(:exp) { 2.0 }
    let(:e_base) { 16.0 }

    [
      [0.0, 0.0],
      [1.0, 16.0],
      [2.0, 64.0],
      [10.0, 1600.0],
    ].each do |a|
      size = a[0]
      egy = a[1]  
      it "energy/size round trip size:#{size} egy:#{egy}" do
        expect(ef.energy(size)).to be_within(tol).of(egy)
        expect(ef.size(egy)).to be_within(tol).of(size)
      end
    end
  end

  context "Exceptions" do
    it "exponent 0" do
      expect{ EnergyFn.new(0.0, 1.0) }.to raise_error("exp (0.0) cannot be <= 0")
    end

    it "exponent < 0" do
      expect{ EnergyFn.new(-1.0, 1.0) }.to raise_error("exp (-1.0) cannot be <= 0")
    end

    it "e_base < 0" do
      expect{ EnergyFn.new(1.0, -1.0) }.to raise_error("e_base (-1.0) cannot be < 0")
    end

    it "negative energy" do
      expect{ef.size(-0.004)}.to raise_error("energy (-0.004) cannot be < 0")
    end

    it "negative size" do
      expect{ef.energy(-0.3)}.to raise_error("size (-0.3) cannot be < 0")
    end
  end
end