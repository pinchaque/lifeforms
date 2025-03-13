include Skill

describe "Distrib" do
  let(:mean) { 100.0 }
  let(:stddev) { 10.0 }
  let(:min) { mean - (4 * stddev) }
  let(:max) { mean + (4 * stddev) }
  let(:rnd) { dist.rnd }
  let(:reps) { 100 }

  context "DistribLinear" do
    let(:dist) { DistribLinear.new(min, max) }
    let(:klass) { "Skill::DistribLinear" }
    it "generates random values within range" do
      (0...reps).each do |i|
        expect(rnd).to be_between(min, max).inclusive
      end
    end

    it "generates mutated values within range" do
      (0...reps).each do |i|
        expect(dist.mutate(mean)).to be_between(min, max).inclusive
      end
    end

    it "marshals and unmarshals" do
      h_exp = {class: klass, min: min, max: max}
      h_act = dist.marshal
      expect(h_act).to eq(h_exp)

      dist_new = Distrib.unmarshal(h_act)
      expect(dist_new.class.name).to eq(klass)
      expect(dist_new.min).to eq(min)
      expect(dist_new.max).to eq(max)
    end
  end
  
  context "DistribNormal" do
    let(:dist) { DistribNormal.new(mean, stddev) }
    let(:klass) { "Skill::DistribNormal" }
    it "generates random values within range" do
      (0...reps).each do |i|
        # not perfect but should be good
        expect(rnd).to be_between(min, max).inclusive
      end
    end

    it "generates mutated values within range" do
      shift = 2000
      (0...reps).each do |i|
        expect(dist.mutate(mean + shift)).to be_between(min + shift, max + shift).inclusive
      end
    end

    it "marshals and unmarshals" do
      h_exp = {class: klass, mean: mean, stddev: stddev}
      h_act = dist.marshal
      expect(h_act).to eq(h_exp)

      dist_new = Distrib.unmarshal(h_act)
      expect(dist_new.class.name).to eq(klass)
      expect(dist_new.mean).to eq(mean)
      expect(dist_new.stddev).to eq(stddev)
    end
  end
end
