require '../lib/config'

describe "Location" do
  let(:tol) { 0.00001 }
  let(:width) { 100.0 }
  let(:height) { 1000.0 }

  (0...100).each do 
    context "constructor" do
      let(:x) { Random.rand(0.0..width) }
      let(:y) { Random.rand(0.0..height) }
      let(:loc) { Location.new(x, y) }
      it "#new" do
        expect(loc.x).to be_within(tol).of(x)
        expect(loc.y).to be_within(tol).of(y)
      end
    end
  end

  (0...100).each do 
    context "#random" do
      let(:loc) { Location.random(width, height) }
      it "generates random coordinates within specified width and height" do
        expect(loc.x).to be_between(0.0, width).inclusive
        expect(loc.y).to be_between(0.0, height).inclusive
      end
    end
  end

  context "#at_dist" do
    let(:loc) { Location.at_dist(width, height, other, dist) }

    (0...100).each do 
      context "other in center of canvas" do
        let(:other) { Location.new(width / 2.0, height / 2.0) }
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
        let(:other) { Location.random(width, height) }
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