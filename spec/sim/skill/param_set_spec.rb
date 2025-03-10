include Skill

describe "ParamSet" do
  let(:mean) { 100.0 }
  let(:stddev) { 10.0 }
  let(:min) { mean - 4 * stddev }
  let(:max) { mean + 4 * stddev }
  let(:dist) { DistribNormal.new(mean, stddev) }
  let(:id) { :foobar }
  let(:desc) { "Test ParamDef" }
  let(:pd) { 
    ParamDefNormal(
      id: id, 
      mean: mean, 
      stddev: stddev, 
      min: min, 
      max: max,
      desc: desc)
  }
  let(:prm) { Param.new(pd) }
  let(:pset) { ParamSet.new }

  context ".initialize" do
    it "creates empty ParamSet" do
      expect(pset.count).to eq(0)
    end
  end

  context "add/include/value/clear" do
    it "handles basic functionality" do
      # empty to start
      expect(pset.count).to eq(0)
      expect(pset.include?(id)).to be false
      expect(pset.value(id)).to be_nil

      # include the param
      pset.add(prm)
      expect(pset.count).to eq(1)
      expect(pset.include?(id)).to be true
      expect(pset.value(id)).to eq(prm.value)

      # back to empty
      pset.clear
      expect(pset.count).to eq(0)
      expect(pset.include?(id)).to be false
      expect(pset.value(id)).to be_nil
    end
  end

  context ".value" do
    let(:dflt) { 9.99 }
    it "handles default values" do
      expect(pset.value(id)).to be_nil
      expect(pset.value(id, dflt)).to eq(dflt)
    end
  end
end
