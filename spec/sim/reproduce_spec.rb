describe "Reproduce" do
  let(:tol) { 0.0001 }
  let(:energy_parent) { 50.0 }
  let(:energy_offspring) { 22.2 }
  let(:tlf) {
    l = TestLF.new
    l.val1 = "foo"
    l.val2 = 42
    l.energy = energy_parent
    l.size = 1.0
    l.name = "Incredible Juniper"
    l.id = '12345'
    l.generation = 3
    l
  }

  context ".generate" do
    context "single offspring" do
      let(:num_offspring) { 1 }

      it "generates offspring" do
        r = Reproduce.new(tlf)
        children = r.generate(energy_offspring, num_offspring)
        expect(children.count).to eq(num_offspring)

        children.each do |c|
          expect(c.val1).to eq("foo")
          expect(c.val2).to eq(42)
          expect(c.energy).to be_within(tol).of(energy_offspring)
          expect(c.size).to be_within(tol).of(tlf.size)
          expect(c.name).not_to eq(tlf.name)
          expect(c.generation).to eq(tlf.generation + 1)
          expect(c.name).not_to be_nil
          #expect(c.x).to be_between(0.0, width).inclusive
          #expect(c.y).to be_between(0.0, height).inclusive  
          expect(c.id).to be_nil # not saved
          expect(c.parent_id).to eq(tlf.id)
        end

        # parent energy shouldn't have changed
        expect(tlf.energy).to be_within(tol).of(energy_parent)
      end
    end
    
    context "multiple offspring" do
      let(:num_offspring) { 10 }

      it "generates offspring" do
        r = Reproduce.new(tlf)
        children = r.generate(energy_offspring, num_offspring)
        expect(children.size).to eq(num_offspring)

        children.each do |c|
          expect(c.val1).to eq("foo")
          expect(c.val2).to eq(42)
          expect(c.energy).to be_within(tol).of(energy_offspring)
          expect(c.size).to be_within(tol).of(tlf.size)
          expect(c.name).not_to eq(tlf.name)
          expect(c.generation).to eq(tlf.generation + 1)
          expect(c.name).not_to be_nil
          expect(c.id).to be_nil # not saved
          expect(c.parent_id).to eq(tlf.id)
        end

        # parent energy shouldn't have changed
        expect(tlf.energy).to be_within(tol).of(energy_parent)
      end
    end
  end
end
