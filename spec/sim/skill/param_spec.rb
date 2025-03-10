include Skill


describe "Param" do
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

  context ".initialize" do
    it "Creates default parameter value" do
      expect(prm.value).to be_between(min, max).inclusive
      expect(prm.id).to eq(pd.id)
    end
  end

  context ".mutate" do
    it "mutates to new value" do
      old_value = prm.value
      new_value = prm.mutate
      expect(prm.value).to eq(new_value)
      expect(prm.value).to be_between(min, max).inclusive
      expect(prm.value != old_value).to be true
    end
  end
end