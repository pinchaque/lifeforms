describe "Eat" do
  let(:tol) { 0.0001 }
  let(:env) { TestFactory.env }
  let(:klass) { Skill::Eat }
  let(:skill_id) { klass.id }
  let(:energy) { 10.0 }
  let(:energy_other) { 10.0 }
  let(:species_plant) { TestFactory.species(name: 'Plant') }
  let(:species_grazer) { TestFactory.species(name: 'Grazer') }
  let(:eat_max_energy) { 3.0 }

  def add_lf(x, y, energy, species)
    l = TestFactory.lifeform(environment_id: env.id, 
      species_id: species.id, 
      x: x, 
      y: y, 
      energy: energy) 
    l.register_skill(klass)
    l.params.fetch(:eat_max_energy).set(eat_max_energy)
    l.save
    #Log.trace("Added lifeform", lf: l, species: species.name, x: l.x, y: l.y, energy: l.energy, eat_max_energy: eat_max_energy)
    l
  end

  context "Lifeform.register_skill" do
    let(:lf) { add_lf(1.0, 1.0, energy, species_grazer) }
    it "registers successfully" do
      expect(lf.skills.include?(skill_id))
      klass.param_defs.each do |pd|
        expect(lf.params.include?(pd.id)).to be true
      end
    end
  end


  RSpec.shared_examples "Eat.eval" do
    it ".eval" do
      other_lfs.each do |l| # instantiate other lifeforms
        l.energy = energy_other
        l.save
      end
      egy_exp = lf.energy + egy_delta_exp
      ret_act = klass.eval(ctx) # run the action on lf
      expect(ret_act).to be_within(tol).of(egy_delta_exp)
      expect(lf.energy).to be_within(tol).of(egy_exp)

      # verify energy state of all other lifeforms
      (0...other_lfs.count).each do |idx|
        l = other_lfs[idx]

        if idx == prey_idx
          expect(l.energy).to eq(energy_other - egy_delta_exp)
        else
          expect(l.energy).to eq(energy_other)
        end
      end
    end
  end
  
  context ".eval" do
    let(:lf) { add_lf(0.0, 0.0, energy, species_grazer) }
    let(:ctx) { lf.context }
    let(:energy) { 6.0 }
    let(:eat_max_energy) { 1.5 }
    let(:other_lfs) { [] }
    let(:prey_idx) { nil }
    let(:egy_delta_exp) { 0.0 }

    context "no other lifeforms" do
      it_behaves_like "Eat.eval" do
      end
    end

    context "no prey lifeforms" do
      it_behaves_like "Eat.eval" do
        let(:other_lfs) { [
          add_lf(1.0, 0.0, energy_other, species_grazer) # not prey
        ] }
      end
    end

    context "prey outside of range, can't eat" do
      it_behaves_like "Eat.eval" do
        let(:other_lfs) { [
          add_lf(6.0, 0.0, energy_other, species_plant)
        ] }
      end            
    end

    context "prey in range, limited by my max" do
      it_behaves_like "Eat.eval" do
        let(:eat_max_energy) { 2.0 }
        let(:energy_other) { 10.0 }
        let(:other_lfs) { [
          add_lf(0.49, 0.0, energy_other, species_plant)
        ] }
        let(:egy_delta_exp) { 2.0 }
      end                  
    end

    context "prey in range, limited by prey's energy" do
      it_behaves_like "Eat.eval" do
        let(:eat_max_energy) { 20.0 }
        let(:energy_other) { 10.0 }
        let(:other_lfs) { [
          add_lf(0.49, 0.0, energy_other, species_plant)
        ] }
        let(:egy_delta_exp) { 10.0 }
      end                  
    end
  end
end