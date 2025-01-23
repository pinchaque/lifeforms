RSpec.configure do |config|
  # too verbose otherwise
  config.default_formatter = "progress"
end

describe "LifeformLoc" do
  let(:tol) { 0.00001 }
  let(:width) { 100.0 }
  let(:height) { 1000.0 }

  context ".to_s" do
    [
        [LifeformLoc.new(x: 10.000003, y: 98.15678), "(10.00, 98.16)"],
        [LifeformLoc.new(x: 10.000003, y: 98.15478), "(10.00, 98.15)"],
        [LifeformLoc.new(x: 0.0000004, y: -100001.9999), "(0.00, -100002.00)"],
    ].each do |ex|
      it "formats correctly" do
        loc = ex.shift
        exp = ex.shift
        expect(loc.to_s).to eq(exp)
      end
    end
  end

  (0...100).each do 
    context "constructor" do
      let(:x) { Random.rand(0.0..width) }
      let(:y) { Random.rand(0.0..height) }
      let(:loc) { LifeformLoc.new(x: x, y: y) }
      it "#new" do
        expect(loc.x).to be_within(tol).of(x)
        expect(loc.y).to be_within(tol).of(y)
      end
    end
  end

  (0...100).each do 
    context "#random" do
      let(:loc) { LifeformLoc.random(width, height) }
      it "generates random coordinates within specified width and height" do
        expect(loc.x).to be_between(0.0, width).inclusive
        expect(loc.y).to be_between(0.0, height).inclusive
      end
    end
  end

  context "#at_dist" do
    let(:loc) { LifeformLoc.at_dist(width, height, other, dist) }

    (0...100).each do 
      context "other in center of canvas" do
        let(:other) { LifeformLoc.new(x: width / 2.0, y: height / 2.0) }
        let(:dist) { [width / 2.0, height / 2.0].min }
        it "generates random coordinates within specified distance" do

          # should be within the canvas
          expect(loc.x).to be_between(0.0, width).inclusive
          expect(loc.y).to be_between(0.0, height).inclusive

          # should be "dist" away because distance is always within the 
          # canvas
          dist_act = Math.sqrt(((loc.x - other.x) ** 2) + ((loc.y - other.y) ** 2))
          expect(dist_act).to be_within(tol).of(dist)
        end
      end
    end

    (0...1000).each do 
      context "other anywhere on canvas" do
        let(:other) { LifeformLoc.random(width, height) }
        let(:dist) { [width / 1.5, height / 1.5].min }
        it "generates random coordinates within specified distance" do

          # should be within the canvas
          expect(loc.x).to be_between(0.0, width).inclusive
          expect(loc.y).to be_between(0.0, height).inclusive

          # should be no more than "dist" away
          dist_act = Math.sqrt(((loc.x - other.x) ** 2) + ((loc.y - other.y) ** 2))
          expect(dist_act - tol).to be <= dist
        end
      end
    end
  end
end