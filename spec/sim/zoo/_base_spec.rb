describe "Zoo::Base" do
  class TestAnimal < Zoo::Base
    def set_attrs(ta)
      ta.energy = 1.23
    end
  end

  let(:sname) { "TestAnimalFoo" }
  let(:env) { TestFactory.env }
  let(:species) { TestFactory.species(name: sname, class_name: "TestAnimal") }
  let(:ta) { TestAnimal.new(env, species) }

  context ".initialize" do
    it "creates TestAnimal factory" do
      expect(ta.env.id).to eq(env.id)
      expect(ta.species.id).to eq(species.id)
      expect(ta.species.name).to eq(sname)
    end
  end

  context ".gen" do
    it "generates lifeform" do
      lf = ta.gen
      expect(lf.id).to be_nil # not saved
      expect(lf.env.id).to eq(env.id)
      expect(lf.energy).to eq(1.23)
      expect(lf.species.id).to eq(species.id)
      expect(lf.species.name).to eq(sname)
    end
  end
end