include Skill

describe "Distrib" do
  let(:reps) { 100 }
  let(:mean) { 100.0 }
  let(:stddev) { 10.0 }
  let(:min) { mean - 4 * stddev }
  let(:max) { mean + 4 * stddev }
  let(:dist) { DistribNormal.new(mean, stddev) }
  let(:id) { :foobar }
  let(:pd) { 
    p = ParamDef.new(id) 
    p.distrib = dist
    p.value_min = min
    p.value_max = max
    p.desc = "Test ParamDef"
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
  end
end