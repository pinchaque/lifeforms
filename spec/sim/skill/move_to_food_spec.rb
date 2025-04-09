describe "MoveToFood" do
  let(:tol) { 0.0001 }
  let(:env) { TestFactory.env }
  let(:klass) { Skill::MoveToFood }
  let(:skill_id) { klass.id }
  let(:energy) { 10.0 }
  let(:species_plant) { TestFactory.species('Plant') }
  let(:species_grazer) { TestFactory.species('Grazer') }
  let(:move_dist) { 5.0 }
  let(:move_energy) { 3.0 }

  def add_lf(x, y, energy, species)
    l = TestFactory.lifeform(environment_id: env.id, 
      species_id: species.id, 
      x: x, 
      y: y, 
      energy: energy)
    l.register_skill(klass)
    l.params.fetch(:move_dist).set(move_dist)
    l.params.fetch(:move_energy).set(move_energy)
    l.save
    #Log.trace("Added lifeform", lf: l, species: species.name, x: l.x, y: l.y, energy: l.energy)
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

  context ".max_dist*" do
    let(:lf) { add_lf(1.0, 1.0, energy, species_grazer) }
    let(:ctx) { lf.context }

    context "energy = 12 / move_energy = 3" do
      let(:energy) { 12.0 }
      let(:move_energy) { 3.0 }

      context "move_dist = 5" do
        let(:move_dist) { 5.0 }
        it "calculates" do
          expect(klass.max_dist_energy_limited(ctx)).to be_within(tol).of(4.0)
          expect(klass.max_dist(ctx)).to be_within(tol).of(4.0)
        end
      end

      context "move_dist = 2" do
        let(:move_dist) { 2.0 }
        it "calculates" do
          expect(klass.max_dist_energy_limited(ctx)).to be_within(tol).of(4.0)
          expect(klass.max_dist(ctx)).to be_within(tol).of(2.0)
        end
      end
    end

    context "energy = 10 / move_energy = 20" do
      let(:energy) { 10.0 }
      let(:move_energy) { 20.0 }
      it "calculates" do
        expect(klass.max_dist_energy_limited(ctx)).to be_within(tol).of(0.5)
      end
    end
  end

  RSpec.shared_examples "MoveToFood.eval" do
    it ".eval" do
      other_lfs.each { |l| l.save } # instantiate other lifeforms
      ret_act = klass.eval(ctx) # run the action on lf
      expect(lf.coord.x).to be_within(tol).of(coord_exp.x)
      expect(lf.coord.y).to be_within(tol).of(coord_exp.y)
      expect(lf.coord.to_s).to eq(coord_exp.to_s)
      expect(ret_act).to be_within(tol).of(ret_exp)
      expect(lf.energy).to be_within(tol).of(egy_exp)
    end
  end
  
  context ".eval" do
    let(:lf) { add_lf(0.0, 0.0, energy, species_grazer) }
    let(:ctx) { lf.context }
    let(:energy) { 6.0 }
    let(:move_energy) { 1.5 }
    let(:move_dist) { 2.0 }

    context "no other lifeforms" do
      it_behaves_like "MoveToFood.eval" do
        let(:other_lfs) { [] }
        let(:coord_exp) { Coord.xy(0.0, 0.0) }
        let(:ret_exp) { 0.0 }
        let(:egy_exp) { 6.0 }
      end
    end

    context "no prey lifeforms" do
      it_behaves_like "MoveToFood.eval" do
        let(:other_lfs) { [
          add_lf(1.0, 0.0, energy, species_grazer) # not prey
        ] }
        let(:coord_exp) { Coord.xy(0.0, 0.0) }
        let(:ret_exp) { 0.0 }
        let(:egy_exp) { 6.0 }
      end
    end

    context "prey within range" do
      it_behaves_like "MoveToFood.eval" do
        let(:other_lfs) { [
          add_lf(1.0, 0.0, energy, species_plant)
        ] }
        let(:coord_exp) { Coord.xy(1.0, 0.0) }
        let(:ret_exp) { 1.0 }
        let(:egy_exp) { 4.5 }
      end      
    end

    context "prey within range, starts at 1,1" do
      it_behaves_like "MoveToFood.eval" do
        let(:lf) { add_lf(1.0, 1.0, energy, species_grazer) }
        let(:other_lfs) { [
          add_lf(2.0, 1.0, energy, species_plant)
        ] }
        let(:coord_exp) { Coord.xy(2.0, 1.0) }
        let(:ret_exp) { 1.0 }
        let(:egy_exp) { 4.5 }
      end      
    end

    context "prey outside of range, limited by max_dist" do
      it_behaves_like "MoveToFood.eval" do
        let(:other_lfs) { [
          add_lf(6.0, 0.0, energy, species_plant)
        ] }
        let(:coord_exp) { Coord.xy(2.0, 0.0) }
        let(:ret_exp) { 2.0 }
        let(:egy_exp) { 3.0 }
      end            
    end

    context "prey outside of range, limited by max_dist, starts at 1,1" do
      it_behaves_like "MoveToFood.eval" do
        let(:lf) { add_lf(1.0, 1.0, energy, species_grazer) }
        let(:other_lfs) { [
          add_lf(7.0, 1.0, energy, species_plant)
        ] }
        let(:coord_exp) { Coord.xy(3.0, 1.0) }
        let(:ret_exp) { 2.0 }
        let(:egy_exp) { 3.0 }
      end            
    end

    context "prey outside of range, limited by energy" do
      it_behaves_like "MoveToFood.eval" do
        let(:energy) { 2.25 }
        let(:move_energy) { 1.5 }
        let(:other_lfs) { [
          add_lf(6.0, 0.0, energy, species_plant)
        ] }
        let(:coord_exp) { Coord.xy(1.5, 0.0) }
        let(:ret_exp) { 1.5 }
        let(:egy_exp) { 0.0 }
      end            
    end

    context "multiple prey options, move to closest" do
      it_behaves_like "MoveToFood.eval" do
        let(:other_lfs) { [
          add_lf(6.0, 6.0, energy, species_plant),
          add_lf(6.0, 0.0, energy, species_plant),
          add_lf(0.0, 6.5, energy, species_plant)
        ] }
        let(:coord_exp) { Coord.xy(2.0, 0.0) }
        let(:ret_exp) { 2.0 }
        let(:egy_exp) { 3.0 }
      end                  
    end
  end
end