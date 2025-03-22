describe "Expr::Base" do
  context ".short_class_name" do
    it "returns short name" do
      expect(e_true.short_class_name).to eq("True")
      expect(e_and(e_true).short_class_name).to eq("And")
    end
  end

  context "#full_class_name" do
    it "returns qualified name" do
      expect(Expr::Base.full_class_name("And")).to eq("Expr::And")
    end
  end
end
