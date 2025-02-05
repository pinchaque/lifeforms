
describe "Plant" do
  let(:tol) { 0.0001 }
  let(:species) { Species.new(name: "Test Lifeform").save }
  let(:env_energy) { 10.0 }
  let(:env) { Environment.new(width: 100, height: 100, time_step: 0, energy_rate: env_energy).save }
  let(:marshal_data) {{
    :energy_absorb_perc => 0.5, 
    :energy_metabolic_rate => 1.2, 
    :energy_size_ratio => 2.0, 
    :growth_invest_perc => 0.4, 
    :repro_energy_inherit_perc => 0.8, 
    :repro_num_offspring => 3, 
    :repro_threshold => 20.0
  }}
  let(:lf) {
    lf = Plant.new
    lf.environment_id = env.id
    lf.species_id = species.id
    lf.energy = 10.0
    lf.size = 1.0
    lf.name = "Incredible Juniper"
    lf.energy_absorb_perc = marshal_data[:energy_absorb_perc]
    lf.energy_metabolic_rate = marshal_data[:energy_metabolic_rate]
    lf.energy_size_ratio = marshal_data[:energy_size_ratio]
    lf.growth_invest_perc = marshal_data[:growth_invest_perc]
    lf.repro_threshold = marshal_data[:repro_threshold]
    lf.repro_num_offspring = marshal_data[:repro_num_offspring]
    lf.repro_energy_inherit_perc = marshal_data[:repro_energy_inherit_perc]
    lf.save
  }
  let(:loc) {
    LifeformLoc.new(x: 9.9, y: 7.7, lifeform_id: lf.id, environment_id: env.id).save
  }

  context ".marshal_to_h" do
    it "marshals to hash" do
      expect(lf.marshal_to_h).to eq(marshal_data)
    end
  end

  context ".marshal_from_h" do
    it "marshals from hash" do
      lfnew = Plant.new
      lfnew.marshal_from_h(marshal_data)
      expect(lf.energy_absorb_perc).to eq(marshal_data[:energy_absorb_perc])
      expect(lf.energy_metabolic_rate).to eq(marshal_data[:energy_metabolic_rate])
      expect(lf.energy_size_ratio).to eq(marshal_data[:energy_size_ratio])
      expect(lf.growth_invest_perc).to eq(marshal_data[:growth_invest_perc])
      expect(lf.repro_threshold).to eq(marshal_data[:repro_threshold])
      expect(lf.repro_num_offspring).to eq(marshal_data[:repro_num_offspring])
      expect(lf.repro_energy_inherit_perc).to eq(marshal_data[:repro_energy_inherit_perc])
      expect(lfnew.marshal_to_h).to eq(marshal_data) # confirm round trip
    end
  end

  context ".area" do
    it "computes area" do
      [
        {size: 1.0, exp: 0.7853981633974483},
        {size: 0.5, exp: 0.19634954084936207},
        {size: 10.0, exp: 78.53981633974483},
      ].each do |h|
        lf.size = h[:size]
        expect(lf.area).to be_within(tol).of(h[:exp])
      end
    end
  end

  context ".env_energy" do
    
  end

  context ".metabolic_energy" do
    it "computes metabolic energy" do
      lf.energy_metabolic_rate = 2.0
      lf.size = 10.0
      exp = 78.53981633974483 * 2.0 # area * rate
      expect(lf.metabolic_energy).to be_within(tol).of(exp)
    end    
  end

  context ".resize_for_energy" do
    
  end

  context ".offspring_energy_tot" do
    
  end

  context ".offspring_energy_each" do
    
  end

  context ".reproduce" do
    
  end

  context ".run_step" do
    
  end
end