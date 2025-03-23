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

  context ".mutate" do
    it "mutates param value" do
      # include the param
      pset.add(prm)
      expect(pset.count).to eq(1)
      expect(pset.include?(id)).to be true
      old_value = prm.value
      expect(pset.fetch(id).value).to eq(old_value)
      pset.mutate
      expect(pset.fetch(id).value).not_to eq(old_value)
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
    let(:id2) { "quux" } # tests string -> sym conversion
    let(:pd2) { 
      ParamDefNormal(
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

      m_exp = [
        prm.marshal,
        prm2.marshal
      ]
      m_act = pset.marshal
      expect(m_act).to eq(m_exp)

      # execute a round trip through JSON like we would for the db
      m_act_json = JSON.parse(JSON.generate(m_act), {symbolize_names: true})

      pset_new = ParamSet.unmarshal(m_act_json)
      expect(pset_new.count).to eq(2)
      expect(pset_new.include?(id)).to be true
      expect(pset_new.include?(id2)).to be true
    end
  end
end