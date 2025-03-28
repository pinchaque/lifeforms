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

  context "arithmetic" do
    def t(c, x_exp, y_exp)
      expect(c.x).to be_within(tol).of(x_exp)
      expect(c.y).to be_within(tol).of(y_exp)
    end

    it "adds" do
      t(Coord.xy(3.0, 4.0) + Coord.xy(1.5, 2.5), 4.5, 6.5)
      t(Coord.xy(-3.0, -4.0) + Coord.xy(1.5, 2.0), -1.5, -2.0)
    end

    it "subtracts" do
      t(Coord.xy(3.0, 4.0) - Coord.xy(1.5, 6.0), 1.5, -2.0)
      t(Coord.xy(13.0, -4.0) - Coord.xy(1.5, -12.0), 11.5, 8.0)
    end
  end

  context "equality" do
    let(:c0) { Coord.xy(3.0, 4.0) }
    let(:c1) { Coord.xy(1.5, -3.5) }
    let(:c2) { Coord.xy(4.5, 0.5) }

    it "identity" do
      [c0, c1, c2].each do |c|
        expect(c == c).to be true
        expect(c != c).to be false
      end
    end

    it "equality without identity" do
      c_empty = Coord.new
      [c0, c1, c2].each do |c|
        expect((c + c_empty) == c).to be true
        expect((c + c_empty) != c).to be false
      end
    end

    it "inequality" do
      [[c0, c1], [c1, c2], [c0, c2]].each do |p|
        expect(p[0] != p[1]).to be true
        expect(p[0] == p[1]).to be false
        expect(p[1] != p[0]).to be true
        expect(p[1] == p[0]).to be false
      end
    end

    it "equality after arithmetic" do
      expect((c0 + c1) == c2).to be true
      expect((c2 - c1) == c0).to be true
      expect((c2 - c0) == c1).to be true
      expect((c2 - c0 - c1) == Coord.new).to be true
      expect((c0 + c1 - c2) == Coord.new).to be true
    end
  end

  context "distance calculations" do
    def t_dist(x0, y0, x1, y1, dist_exp)
      c0 = Coord.xy(x0, y0)
      c1 = Coord.xy(x1, y1)
      c_diff = c1 - c0
      expect(c_diff.r).to be_within(tol).of(dist_exp)
    end

    it "no distance" do
      t_dist(1.0, 2.0, 1.0, 2.0, 0.0)
    end
  
    it "x distance" do
      t_dist(1.0, 2.0, 3.0, 2.0, 2.0)
    end
  
    it "y distance" do
      t_dist(1.0, 2.0, 1.0, 12.0, 10.0)
    end
  
    it "x and y distance" do
      t_dist(1.0, 2.2, -2.0, 6.2, 5.0)
    end
  end
end
