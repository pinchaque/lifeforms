describe "Helpers" do  
  let(:tol) { 0.000001 }
  context "circle_area_intersect" do
    it "no overlap" do
      act = circle_area_intersect(0, 0, 1, 4, 0, 2)
      expect(act).to be_within(tol).of(0.0)
    end

    it "full overlap" do
      act = circle_area_intersect(0, 0, 1, 0, 0, 1)
      expect(act).to be_within(tol).of(Math::PI)
    end

    it "full containment" do
      act = circle_area_intersect(0, 0, 1, 1, 0, 4)
      expect(act).to be_within(tol).of(Math::PI)
    end

    it "half overlap" do
      act = circle_area_intersect(0, 0, 1, 1, 0, 1)
      expect(act).to be_within(tol).of(1.2283696986087564)
    end

    it "some overlap" do
      act = circle_area_intersect(0, 0, 2, 3, 0, 2)
      expect(act).to be_within(tol).of(1.0)
    end
  end
end