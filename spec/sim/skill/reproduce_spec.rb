describe "Reproduce" do
  let(:tol) { 0.0001 }
  let(:energy_parent) { 50.0 }
  let(:energy_offspring) { 22.2 }
  let(:species) { TestFactory.species }
  let(:width) { 100 }
  let(:height) { 100 }
  let(:time_step) { 5 }
  let(:env) { TestFactory.env(width, height, time_step) }
  let(:lf) { 
    l = TestFactory.lifeform(env, species) 
    l.energy = energy_parent
    l.save
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
          expect(c.size).to be_within(tol).of(tlf.initial_size) # starting size
          expect(c.initial_size).to be_within(tol).of(tlf.initial_size)
          expect(c.name).not_to eq(tlf.name)
          expect(c.generation).to eq(tlf.generation + 1)
          expect(c.name).not_to be_nil
          expect(c.died_step).to be_nil
          expect(c.created_step).to eq(env.time_step)
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
          expect(c.size).to be_within(tol).of(tlf.initial_size) # starting size
          expect(c.initial_size).to be_within(tol).of(tlf.initial_size)
          expect(c.name).not_to eq(tlf.name)
          expect(c.generation).to eq(tlf.generation + 1)
          expect(c.name).not_to be_nil
          expect(c.died_step).to be_nil
          expect(c.created_step).to eq(env.time_step)
          expect(c.id).to be_nil # not saved
          expect(c.parent_id).to eq(tlf.id)
        end

        # parent energy shouldn't have changed
        expect(tlf.energy).to be_within(tol).of(energy_parent)
      end
    end
  end
end
