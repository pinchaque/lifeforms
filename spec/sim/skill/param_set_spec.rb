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
    Skill::ParamDefNormal(
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
      expect(pset.fetch(id)).to be_nil

      # include the param
      pset.add(prm)
      expect(pset.count).to eq(1)
      expect(pset.include?(id)).to be true
      expect(pset.fetch(id).value).to eq(prm.value)

      # back to empty
      pset.clear
      expect(pset.count).to eq(0)
      expect(pset.include?(id)).to be false
      expect(pset.fetch(id)).to be_nil
    end
  end

  context "exceptions" do
    it "rejects duplicate params" do
      pset.add(prm)
      expect(pset.count).to eq(1)
      expect{pset.add(prm)}.to raise_error("Param foobar already exists")
      expect(pset.count).to eq(1)
    end
  end

  context "marshalling" do
    let(:id2) { "quux" }
    let(:pd2) { 
      Skill::ParamDefNormal(
        id: id2,
        mean: mean, 
        stddev: stddev, 
        min: min, 
        max: max,
        desc: desc)
    }
    let(:prm2) { Param.new(pd2) }
    it "marshals and unmarshals" do
      pset.add(prm)
      pset.add(prm2)
      expect(pset.count).to eq(2)

      h_exp = {
        id => prm.marshal_to_h,
        id2 => prm2.marshal_to_h
      }
      h_act = pset.marshal_to_h
      expect(h_act).to eq(h_exp)

      pset_new = ParamSet.unmarshal_from_h(h_act)
      expect(pset_new.count).to eq(2)
      expect(pset_new.include?(id)).to be true
      expect(pset_new.include?(id2)).to be true
    end
  end
end