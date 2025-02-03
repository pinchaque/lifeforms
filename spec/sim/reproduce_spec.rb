describe "Reproduce" do
  let(:tol) { 0.0001 }
  let(:energy_tot) { 100.0 }
  let(:tlf) {
    l = TestLF.new
    l.val1 = "foo"
    l.val2 = 42
    l.energy = energy_tot
    l.size = 1.0
    l.name = "Incredible Juniper"
    l.id = '12345'
    l.generation = 3
    l
  }

  context ".generate" do
    it "generates 1 child" do
      r = Reproduce.new(tlf)
      children = r.generate(1)
      expect(children.size).to eq(1)
      c = children.shift
      energy_exp = energy_tot / 2.0

      expect(c.val1).to eq("foo")
      expect(c.val2).to eq(42)
      expect(c.energy).to be_within(tol).of(energy_exp)
      expect(c.size).to be_within(tol).of(tlf.size)
      expect(c.name).not_to eq(tlf.name)
      expect(c.generation).to eq(tlf.generation + 1)
      expect(c.name).not_to be_nil
      expect(c.id).to be_nil # not saved
      expect(c.parent_id).to eq(tlf.id)
  
      # parent should have less energy
      expect(tlf.energy).to be_within(tol).of(energy_exp)
    end
  end
end
