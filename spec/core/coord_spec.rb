describe "Coord" do
  let(:tol) { 0.00001 }


  context "construction" do
    def t(x, y, r, ang)
      [Coord.xy(x, y), Coord.polar(r, ang)].each do |c|
        expect(c.x).to be_within(tol).of(x)
        expect(c.y).to be_within(tol).of(y)
        expect(c.r).to be_within(tol).of(r)
        expect(c.ang).to be_within(tol).of(ang)
      end
    end

    it "cartesian 0, 0" do
      t(0.0, 0.0, 0.0, 0.0)
    end

    it "cartesian 1, 0" do
      t(1.0, 0.0, 1.0, 0.0)
    end

    it "cartesian 1, 1" do
      t(1.0, 1.0, Math.sqrt(2), 0.25 * Math::PI)
    end

    it "cartesian 0, 1" do
      t(0.0, 1.0, 1.0, 0.5 * Math::PI)
    end

    it "cartesian -1, 1" do
      t(-1.0, 1.0, Math.sqrt(2), 0.75 * Math::PI)
    end

    it "cartesian -1, 0" do
      t(-1.0, 0.0, 1.0, Math::PI)
    end

    it "cartesian -1, -1" do
      t(-1.0, -1.0, Math.sqrt(2), -0.75 * Math::PI)
    end

    it "cartesian 0, -1" do
      t(0.0, -1.0, 1.0, -0.5 * Math::PI)
    end

    it "cartesian 1, -1" do
      t(1.0, -1.0, Math.sqrt(2), -0.25 * Math::PI)
    end
  end

  context "xy_dist" do
    it "no distance" do
      expect(xy_dist(1.0, 2.0, 1.0, 2.0)).to be_within(tol).of(0.0)
    end
  
    it "x distance" do
      expect(xy_dist(1.0, 2.0, 3.0, 2.0)).to be_within(tol).of(2.0)
    end
  
    it "y distance" do
      expect(xy_dist(1.0, 2.0, 1.0, 12.0)).to be_within(tol).of(10.0)
    end
  
    it "x and y distance" do
      expect(xy_dist(1.0, 2.2, -2.0, 6.2)).to be_within(tol).of(5.0)
    end
  end
end
