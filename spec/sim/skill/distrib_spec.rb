include Skill

describe "Distrib" do
  let(:mean) { 100.0 }
  let(:stddev) { 10.0 }
  let(:min) { mean - (4 * stddev) }
  let(:max) { mean + (4 * stddev) }
  let(:rnd) { dist.rnd }

  context "DistribLinear" do
    let(:dist) { DistribLinear.new(min, max) }
    it "generates values within range" do
      (0...100).each do |i|
        expect(rnd).to be_between(min, max).inclusive
      end
    end
  end
  
  context "DistribNormal" do
    let(:dist) { DistribNormal.new(mean, stddev) }
    it "generates values within range" do
      (0...100).each do |i|
        # not perfect but should be good
        expect(rnd).to be_between(min, max).inclusive
      end
    end
  end
end
