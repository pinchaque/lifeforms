describe "Zoo::Base" do
  class TestAnimal < Zoo::Base
    def set_params(ta)
      ta.energy = 1.23
    end
  end

  let(:env) { TestFactory.env }
  let(:ta) { TestAnimal.new(env) }

  context ".species_name" do
    it "gets species name from class name" do
      expect(ta.species_name).to eq("TestAnimal")
    end
  end

  context ".species" do
    it "creates species in database" do
      s = ta.get_species
      expect(s.id).not_to be_nil # was saved

      s_act = Species.where(name: "TestAnimal").first
      expect(s_act).not_to be_nil
      expect(s_act.id).to eq(s.id)
      expect(s_act.name).to eq("TestAnimal")
    end
  end

  context ".initialize" do
    it "creates TestAnimal factory" do
      expect(ta.env.id).to eq(env.id)
      expect(ta.species.name).to eq("TestAnimal")
    end
  end

  context ".gen" do
    it "generates lifeform" do
      lf = ta.gen
      expect(lf.id).to be_nil # not saved
      expect(lf.env.id).to eq(env.id)
      expect(lf.energy).to eq(1.23)
      expect(lf.species.name).to eq("TestAnimal")
    end
  end
end