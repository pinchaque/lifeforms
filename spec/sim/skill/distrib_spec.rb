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
  end
  
  context "DistribNormal" do
    let(:dist) { DistribNormal.new(mean, stddev) }
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
  end
end
