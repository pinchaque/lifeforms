require '../lib/config'

describe "Location" do
  let(:tol) { 0.001 }
  let(:width) { 100.0 }
  let(:height) { 1000.0 }

  context "constructor" do
    it "constructs with arguments" do
      for i in 0...1000
        x = Random.rand(0.0..width)
        y = Random.rand(0.0..height)
        loc = Location.new(x, y)
        expect(loc.x).to be_within(tol).of(x)
        expect(loc.y).to be_within(tol).of(y)
      end
    end
  end

  context ".random" do
    it "generates random coordinates within specified width and height" do
      for i in 0...1000
        loc = Location.random(width, height)
        expect(loc.x).to be_between(0.0, width).inclusive
        expect(loc.y).to be_between(0.0, height).inclusive
      end
    end
  end

  context ".at_dist" do
    it "generates random coordinates within specified distance" do
      for i in 0...1
        loc = Location.at_dist(width, height, other, dist)
        random(width, height)
        expect(loc.x).to be_between(0.0, width).inclusive
        expect(loc.y).to be_between(0.0, height).inclusive
      end
    end
  end
end