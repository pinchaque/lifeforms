include Skill

describe "ParamDef" do
  let(:reps) { 100 }
  let(:mean) { 100.0 }
  let(:stddev) { 10.0 }
  let(:min) { mean - 4 * stddev }
  let(:max) { mean + 4 * stddev }
  let(:dist) { DistribNormal.new(mean, stddev) }
  let(:id) { :foobar }
  let(:desc) { "Test ParamDef" }
  let(:pd) { 
    p = ParamDef.new(id) 
    p.distrib = dist
    p.constraints << ConstraintMinMax.new(min, max)
    p.desc = desc
    p
  }

  context ".constrain" do
    let(:min) { 50 }
    let(:max) { 500 }
      
    it "constrain to min/max" do
      expect(pd.constrain(51)).to eq(51)
      expect(pd.constrain(50)).to eq(50)
      expect(pd.constrain(5)).to eq(50)
      expect(pd.constrain(490)).to eq(490)
      expect(pd.constrain(500)).to eq(500)
      expect(pd.constrain(501)).to eq(500)
    end
  end

  context ".generate_default" do
    it "generates within expected range" do
      (0...reps).each do |i|
        expect(pd.generate_default).to be_between(min, max).inclusive
      end
    end
  end

  context ".mutate" do
    let(:mean) { 50.0 }
    let(:stddev) { 10.0 }
    let(:min) { 0.0 }
    let(:max) { 100.0 }
  
    context "at mean" do
      let(:old_val) { mean }
      it "returns new value" do
        (0...reps).each do |i|
          new_val = pd.mutate(old_val)
          expect(new_val).to be_between(min, max).inclusive
          expect(old_val != new_val).to be true
          expect(pd.valid?(new_val)).to be true
        end
      end
    end
  
    context "near max" do
      let(:old_val) { max - (stddev / 2.0) }
      it "returns new value" do
        (0...reps).each do |i|
          new_val = pd.mutate(old_val)
          expect(new_val).to be_between(min, max).inclusive
          expect(old_val != new_val).to be true
          expect(pd.valid?(new_val)).to be true
        end
      end
    end

    context "below min" do
      let(:old_val) { min - (stddev / 2.0) } 
      it "returns new value" do
        (0...reps).each do |i|
          new_val = pd.mutate(old_val)
          expect(new_val).to be_between(min, max).inclusive
          expect(old_val != new_val).to be true
          expect(pd.valid?(new_val)).to be true
        end
      end
    end
  end

  context "Construct Helpers" do
    context "ParamDefLinear" do      
      it "exceptions" do
        expect{Skill.ParamDefLinear(id: id)}.to raise_error(ArgumentError)
      end

      it "required args" do
        pd = Skill.ParamDefLinear(id: id, min: min, max: max)
        expect(pd.id).to eq(id)
        expect(pd.desc).to be_nil
        expect(pd.constraints.count).to eq(1)
        c = pd.constraints[0]
        expect(c.class.name).to eq("Skill::ConstraintMinMax")
        expect(c.min).to eq(min)
        expect(c.max).to eq(max)
        expect(pd.distrib.class.to_s).to eq("Skill::DistribLinear")
        expect(pd.distrib.min).to eq(min)
        expect(pd.distrib.max).to eq(max)
      end

      it "optional args" do
        pd = Skill.ParamDefLinear(id: id, min: min, max: max, desc: desc)
        expect(pd.id).to eq(id)
        expect(pd.desc).to eq(desc)
        expect(pd.constraints.count).to eq(1)
        c = pd.constraints[0]
        expect(c.class.name).to eq("Skill::ConstraintMinMax")
        expect(c.min).to eq(min)
        expect(c.max).to eq(max)
        expect(pd.distrib.class.to_s).to eq("Skill::DistribLinear")
        expect(pd.distrib.min).to eq(min)
        expect(pd.distrib.max).to eq(max)
      end
    end

    context "ParamDefNormal" do
      it "exceptions" do
        expect{Skill.ParamDefNormal(id: id)}.to raise_error(ArgumentError)
      end

      it "required args" do
        pd = Skill.ParamDefNormal(id: id, mean: mean, stddev: stddev)
        expect(pd.id).to eq(id)
        expect(pd.desc).to be_nil
        expect(pd.constraints.count).to eq(1)
        c = pd.constraints[0]
        expect(c.class.name).to eq("Skill::ConstraintMinMax")
        expect(c.min).to be_nil
        expect(c.max).to be_nil
        expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
        expect(pd.distrib.mean).to eq(mean)
        expect(pd.distrib.stddev).to eq(stddev)
      end

      it "optional args" do
        pd = Skill.ParamDefNormal(id: id, mean: mean, stddev: stddev, min: min, desc: desc)
        expect(pd.id).to eq(id)
        expect(pd.desc).to eq(desc)
        expect(pd.constraints.count).to eq(1)
        c = pd.constraints[0]
        expect(c.class.name).to eq("Skill::ConstraintMinMax")
        expect(c.min).to eq(min)
        expect(c.max).to be_nil
        expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
        expect(pd.distrib.mean).to eq(mean)
        expect(pd.distrib.stddev).to eq(stddev)
      end
    end

    context "ParamDefNormalInt" do
      it "exceptions" do
        expect{Skill.ParamDefNormalInt(id: id)}.to raise_error(ArgumentError)
      end


      it "required args" do
        pd = Skill.ParamDefNormalInt(id: id, mean: mean, stddev: stddev)
        expect(pd.id).to eq(id)
        expect(pd.desc).to be_nil

        expect(pd.constraints.count).to eq(2)
        c0 = pd.constraints[0]
        expect(c0.class.name).to eq("Skill::ConstraintMinMax")
        expect(c0.min).to be_nil
        expect(c0.max).to be_nil
        c1 = pd.constraints[1]
        expect(c1.class.name).to eq("Skill::ConstraintInt")
        expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
        expect(pd.distrib.mean).to eq(mean)
        expect(pd.distrib.stddev).to eq(stddev)
      end

      it "optional args" do
        pd = Skill.ParamDefNormalInt(id: id, mean: mean, stddev: stddev, min: min, desc: desc)
        expect(pd.id).to eq(id)
        expect(pd.desc).to eq(desc)
        c0 = pd.constraints[0]
        expect(c0.class.name).to eq("Skill::ConstraintMinMax")
        expect(c0.min).to eq(min)
        expect(c0.max).to be_nil
        c1 = pd.constraints[1]
        expect(c1.class.name).to eq("Skill::ConstraintInt")
        expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
        expect(pd.distrib.mean).to eq(mean)
        expect(pd.distrib.stddev).to eq(stddev)
      end
    end

    context "ParamDefNormalPerc" do
      it "exceptions" do
        expect{Skill.ParamDefNormalPerc(id: id)}.to raise_error(ArgumentError)
        expect{Skill.ParamDefNormalPerc(id: id, mean: mean, stddev: stddev, min: -0.2)}.to raise_error(ArgumentError, "min and max must be in range 0..1")
        expect{Skill.ParamDefNormalPerc(id: id, mean: mean, stddev: stddev, max: 0.5, min: 1.2)}.to raise_error(ArgumentError, "min and max must be in range 0..1")
      end

      it "required args" do
        pd = Skill.ParamDefNormalPerc(id: id, mean: mean, stddev: stddev)
        expect(pd.id).to eq(id)
        expect(pd.desc).to be_nil
        expect(pd.constraints.count).to eq(1)
        c = pd.constraints[0]
        expect(c.class.name).to eq("Skill::ConstraintMinMax")
        expect(c.min).to eq(0.0)
        expect(c.max).to eq(1.0)
        expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
        expect(pd.distrib.mean).to eq(mean)
        expect(pd.distrib.stddev).to eq(stddev)
      end

      it "optional args" do
        pd = Skill.ParamDefNormalPerc(id: id, mean: mean, stddev: stddev, min: 0.2, desc: desc)
        expect(pd.id).to eq(id)
        expect(pd.desc).to eq(desc)
        expect(pd.constraints.count).to eq(1)
        c = pd.constraints[0]
        expect(c.class.name).to eq("Skill::ConstraintMinMax")
        expect(c.min).to eq(0.2)
        expect(c.max).to eq(1.0)
        expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
        expect(pd.distrib.mean).to eq(mean)
        expect(pd.distrib.stddev).to eq(stddev)
      end
    end
  end

  context "marshalling" do
    let(:min) { 0.0 }
    let(:max) { 1.0 }
    let(:mean) { 0.5 }
    let(:stddev) { 0.1 }
  
    it "marshals and unmarshals" do
      pd = Skill.ParamDefNormalPerc(id: id, mean: mean, stddev: stddev, min: min, max: max, desc: desc)
      expect(pd.id).to eq(id)
      expect(pd.desc).to eq(desc)
      expect(pd.constraints.count).to eq(1)
      c = pd.constraints[0]
      expect(c.class.name).to eq("Skill::ConstraintMinMax")
      expect(c.min).to eq(min)
      expect(c.max).to eq(max)
      expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
      expect(pd.distrib.mean).to eq(mean)
      expect(pd.distrib.stddev).to eq(stddev)

      m_exp = { 
        desc: desc, id: id, 
        constraints: [c.marshal],
        distrib: pd.distrib.marshal
      }
      m_act = pd.marshal
      expect(m_act).to eq(m_exp)

      # execute a round trip through JSON like we would for the db
      m_act_json = JSON.parse(JSON.generate(m_act), {symbolize_names: true})

      pd_new = ParamDef.unmarshal(m_act_json)
      expect(pd_new.id).to eq(id)
      expect(pd_new.desc).to eq(desc)
      expect(pd.constraints.count).to eq(1)
      c = pd.constraints[0]
      expect(c.class.name).to eq("Skill::ConstraintMinMax")
      expect(c.min).to eq(min)
      expect(c.max).to eq(max)
      expect(pd_new.distrib.class.to_s).to eq("Skill::DistribNormal")
      expect(pd_new.distrib.mean).to eq(mean)
      expect(pd_new.distrib.stddev).to eq(stddev)
    end
  end
end