include Skill

describe "Distrib" do
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
    p.value_min = min
    p.value_max = max
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

  context "validity" do
    def t_valid(v, exp_bool, exp_str)
      expect(pd.valid?(v)).to be exp_bool
      cv_act = pd.check_validity(v)
      if exp_str.nil?
        expect(cv_act).to be_nil
      else
        expect(cv_act).to eq(exp_str)
      end
    end

    context "min and max" do
      let(:min) { 50 }
      let(:max) { 500 }
        
      it "validates with expected error message" do
        t_valid(51, true, nil)
        t_valid(50, true, nil)
        t_valid(5, false, "5 is less than minimum value (50)")
        t_valid(490, true, nil)
        t_valid(500, true, nil)
        t_valid(501, false, "501 is greater than maximum value (500)")
      end 
    end

    context "min only" do
      let(:min) { 50 }
      let(:max) { nil }
        
      it "validates with expected error message" do
        t_valid(51, true, nil)
        t_valid(50, true, nil)
        t_valid(5, false, "5 is less than minimum value (50)")
        t_valid(490, true, nil)
        t_valid(500, true, nil)
        t_valid(501, true, nil)
      end 
    end

    context "max only" do
      let(:min) { nil }
      let(:max) { 500 }
        
      it "validates with expected error message" do
        t_valid(51, true, nil)
        t_valid(50, true, nil)
        t_valid(5, true, nil)
        t_valid(490, true, nil)
        t_valid(500, true, nil)
        t_valid(501, false, "501 is greater than maximum value (500)")
      end 
    end

    context "Construct Helpers" do
      context "ParamDefLinear" do      
        it "exceptions" do
          expect{ParamDefLinear(id: id)}.to raise_error(ArgumentError)
        end

        it "required args" do
          pd = ParamDefLinear(id: id, min: min, max: max)
          expect(pd.id).to eq(id)
          expect(pd.desc).to be_nil
          expect(pd.value_min).to eq(min)
          expect(pd.value_max).to eq(max)
          expect(pd.distrib.class.to_s).to eq("Skill::DistribLinear")
          expect(pd.distrib.min).to eq(min)
          expect(pd.distrib.max).to eq(max)
        end

        it "optional args" do
          pd = ParamDefLinear(id: id, min: min, max: max, desc: desc)
          expect(pd.id).to eq(id)
          expect(pd.desc).to eq(desc)
          expect(pd.value_min).to eq(min)
          expect(pd.value_max).to eq(max)
          expect(pd.distrib.class.to_s).to eq("Skill::DistribLinear")
          expect(pd.distrib.min).to eq(min)
          expect(pd.distrib.max).to eq(max)
        end
      end

      context "ParamDefNormal" do
        it "exceptions" do
          expect{ParamDefNormal(id: id)}.to raise_error(ArgumentError)
        end

        it "required args" do
          pd = ParamDefNormal(id: id, mean: mean, stddev: stddev)
          expect(pd.id).to eq(id)
          expect(pd.desc).to be_nil
          expect(pd.value_min).to be_nil
          expect(pd.value_max).to be_nil
          expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
          expect(pd.distrib.mean).to eq(mean)
          expect(pd.distrib.stddev).to eq(stddev)
        end

        it "optional args" do
          pd = ParamDefNormal(id: id, mean: mean, stddev: stddev, min: min, desc: desc)
          expect(pd.id).to eq(id)
          expect(pd.desc).to eq(desc)
          expect(pd.value_min).to eq(min)
          expect(pd.value_max).to be_nil
          expect(pd.distrib.class.to_s).to eq("Skill::DistribNormal")
          expect(pd.distrib.mean).to eq(mean)
          expect(pd.distrib.stddev).to eq(stddev)
        end
      end
    end
  end
end