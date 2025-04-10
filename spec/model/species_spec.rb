describe "Species" do
  let(:species) { TestFactory.species }
  let(:env) { TestFactory.env }

  {
    "Mock Animal" => MockAnimal,
    "Plant" => Zoo::Plant,
    "Grazer" => Zoo::Grazer,
  }.each do |name, klass|
    context name do
      let(:species) { TestFactory.species(name: name) }

      context ".fact_class" do
        it "return expected class" do
          expect(species.fact_class).to eq(klass)
        end
      end

      context ".fact" do
        let(:fact) { species.fact(env) }
        let(:lf) { fact.gen }
        it "generates lifeform of correct type" do
          expect(lf.species.id).to eq(species.id)
          expect(lf.species.name).to eq(species.name)
        end
      end

      context ".gen_lifeform" do
        let(:lf) { species.gen_lifeform(env) }
        it "generates lifeform of correct type" do
          expect(lf.species.id).to eq(species.id)
          expect(lf.species.name).to eq(species.name)
        end
      end
    end
  end
end