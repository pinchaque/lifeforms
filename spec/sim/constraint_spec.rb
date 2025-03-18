describe "Constraint" do
  let(:tol) { 0.0001 }
  let(:mean) { 100.0 }
  let(:stddev) { 10.0 }
  let(:rnd) { dist.rnd }
  let(:reps) { 100 }
  let(:ct) { Constraint.new }

  def t_valid(v, exp_c, exp_bool, exp_str)
    expect(ct.constrain(v)).to be_within(tol).of(exp_c)
    expect(ct.valid?(v)).to be exp_bool
    cv_act = ct.check_validity(v)
    if exp_str.nil?
      expect(cv_act).to be_nil
    else
      expect(cv_act).to eq(exp_str)
    end
  end

  context "MinMax" do
    let(:klass) { "ConstraintMinMax" }
    let(:min) { nil }
    let(:max) { nil }
    let(:ct) { ConstraintMinMax.new(min, max) }

    context "min and max" do
      let(:min) { 50 }
      let(:max) { 500 }
        
      it "validates with expected error message" do
        t_valid(51, 51, true, nil)
        t_valid(50, 50, true, nil)
        t_valid(5, 50, false, "5 is less than minimum value (50)")
        t_valid(490, 490, true, nil)
        t_valid(500, 500, true, nil)
        t_valid(501, 500, false, "501 is greater than maximum value (500)")
      end 

      it "marshals and unmarshals" do
        h_exp = {class: klass, min: min, max: max}
        h_act = ct.marshal
        expect(h_act).to eq(h_exp)
  
        c_new = Constraint.unmarshal(h_act)
        expect(c_new.class.name).to eq(klass)
        expect(c_new.min).to eq(min)
        expect(c_new.max).to eq(max)
      end
    end

    context "min only" do
      let(:min) { 50 }
      let(:max) { nil }
        
      it "validates with expected error message" do
        t_valid(51, 51, true, nil)
        t_valid(50, 50, true, nil)
        t_valid(5, 50, false, "5 is less than minimum value (50)")
        t_valid(490, 490, true, nil)
        t_valid(500, 500, true, nil)
        t_valid(501, 501, true, nil)
      end 
    end

    context "max only" do
      let(:min) { nil }
      let(:max) { 500 }
        
      it "validates with expected error message" do
        t_valid(51, 51, true, nil)
        t_valid(50, 50, true, nil)
        t_valid(5, 5, true, nil)
        t_valid(490, 490, true, nil)
        t_valid(500, 500, true, nil)
        t_valid(501, 500, false, "501 is greater than maximum value (500)")
      end 
    end
  end

  context "Int" do
    let(:klass) { "ConstraintInt" }
    let(:ct) { ConstraintInt.new }
    it "ensures integer" do
      t_valid(51, 51, true, nil)
      t_valid(-50, -50, true, nil)
      t_valid(0, 0, true, nil)
      t_valid(4.49, 4, false, "4.49 is not an integer")
      t_valid(4.50, 5, false, "4.5 is not an integer")
    end

    it "marshals and unmarshals" do
      h_exp = {class: klass}
      h_act = ct.marshal
      expect(h_act).to eq(h_exp)

      c_new = Constraint.unmarshal(h_act)
      expect(c_new.class.name).to eq(klass)
    end
  end
end