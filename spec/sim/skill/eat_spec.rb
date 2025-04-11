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
      # Make sure everything is instantiated
      prey_lf
      lf
      other_lfs.each do |l|
        l
      end

      # verify all lifeforms exist
      expect(env.lifeforms_ds.count).to eq(other_lfs.count + (prey_lf.nil? ? 1 : 2))

      # remember starting energy
      egy_start = {}
      egy_start[prey_lf.id] = prey_lf.energy unless prey_lf.nil?
      other_lfs.each do |l| # instantiate other lifeforms
        egy_start[l.id] = l.energy
      end

      egy_exp = lf.energy + egy_delta_exp
      ret_act = klass.eval(ctx) # run the action on lf
      expect(ret_act).to be_within(tol).of(egy_delta_exp)
      expect(lf.energy).to be_within(tol).of(egy_exp)

      # verify prey had energy deducted
      unless prey_lf.nil?
        p = Lifeform[prey_lf.id] # reload to get new energy
        expect(p.energy).to be_within(tol).of(egy_start[p.id] - egy_delta_exp)
      end
      
      # verify unchanged energy state of all other lifeforms
      other_lfs.each do |l|
        l = Lifeform[l.id] # reload to get new energy
        expect(l.energy).to eq(egy_start[l.id]) # unchanged
      end
    end
  end
  
  context ".eval" do
    let(:lf) { add_lf(0.0, 0.0, energy, species_grazer) }
    let(:ctx) { lf.context }
    let(:energy) { 6.0 }
    let(:eat_max_energy) { 1.5 }
    let(:energy_other) { 10.0 }
    let(:other_lfs) { [] }
    let(:prey_lf) { nil }
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
        let(:prey_lf) { add_lf(0.49, 0.0, energy_other, species_plant) }
        let(:egy_delta_exp) { 2.0 }
      end
    end

    context "prey in range, limited by prey's energy" do
      it_behaves_like "Eat.eval" do
        let(:eat_max_energy) { 20.0 }
        let(:prey_lf) { add_lf(0.49, 0.0, energy_other, species_plant) }
        let(:egy_delta_exp) { 10.0 }
      end
    end

    context "multiple prey in range, select the one with the most energy" do
      it_behaves_like "Eat.eval" do
        let(:eat_max_energy) { 20.0 }
        let(:other_lfs) { [
          add_lf(0.0, 0.3, 3.0, species_plant),
          add_lf(0.0, 0.1, 1.0, species_plant),
          add_lf(0.45, 0.0, 3.9, species_plant),
          add_lf(0.2, 0.0, 2.0, species_plant),
          add_lf(0.35, 0.0, 3.5, species_plant),
          add_lf(0.25, 0.0, 2.5, species_plant)
        ] }
        let(:prey_lf) { add_lf(0.4, 0.0, 4.0, species_plant) }
        let(:egy_delta_exp) { 4.0 }
      end
    end
  end
end