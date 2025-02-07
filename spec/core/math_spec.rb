describe "Helpers" do  
  let(:tol) { 0.000001 }
  context "circle_area_intersect" do
    it "no overlap" do
      act = circle_area_intersect(0, 0, 1, 4, 0, 2)
      expect(act).to be_within(tol).of(0.0)

      act = circle_area_intersect(4, 0, 2, 0, 0, 1)
      expect(act).to be_within(tol).of(0.0)

      act = circle_area_intersect(4, 4, 2, 10, 10, 2)
      expect(act).to be_within(tol).of(0.0)
    end

    it "identical / full overlap" do
      act = circle_area_intersect(0, 0, 1, 0, 0, 1)
      expect(act).to be_within(tol).of(Math::PI)

      act = circle_area_intersect(2, 2, 3, 2, 2, 3)
      expect(act).to be_within(tol).of(Math::PI * 9.0)

      act = circle_area_intersect(0.1, 0.1, 2, 0.1, 0.1, 2)
      expect(act).to be_within(tol).of(Math::PI * 4.0)
    end

    it "full containment" do
      act = circle_area_intersect(0, 0, 1, 1, 0, 4)
      expect(act).to be_within(tol).of(Math::PI)

      act = circle_area_intersect(2, 2, 2, 1, 1, 8)
      expect(act).to be_within(tol).of(Math::PI * 4.0)

      act = circle_area_intersect(1, 1, 8, 2, 2, 2)
      expect(act).to be_within(tol).of(Math::PI * 4.0)
    end

    it "half overlap" do
      act = circle_area_intersect(0, 0, 1, 1, 0, 1)
      expect(act).to be_within(tol).of(1.2283696986087564)
    end

    it "some overlap" do
      act = circle_area_intersect(0, 0, 1, 1.9, 0, 1)
      expect(act).to be_within(tol).of(0.04184604873519482)

      act = circle_area_intersect(0, 0, 1, 1.99, 0, 1)
      expect(act).to be_within(tol).of(0.0013323328864701944)

      act = circle_area_intersect(0, 0, 1, 0.1, 0, 1)
      expect(act).to be_within(tol).of(2.9416760182008863)

      act = circle_area_intersect(0, 0, 1, 0.001, 0, 1)
      expect(act).to be_within(tol).of(3.1395926797957534)
    end
  end
end