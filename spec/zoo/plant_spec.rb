describe "Plant" do
  def add_lf(x, y, size, energy)
    lf = Plant.new
    lf.environment_id = env.id
    lf.created_step = 1
    lf.species_id = species.id
    lf.energy = energy
    lf.size = size
    lf.initial_size = 0.2
    lf.x = x
    lf.y = y
    lf.name = sprintf("add_lf(%f, %f, %f, %f)", x, y, size, energy)
    lf.energy_absorb_perc = marshal_data[:energy_absorb_perc]
    lf.energy_base = marshal_data[:energy_base]
    lf.energy_reserve_perc = marshal_data[:energy_reserve_perc]
    lf.repro_threshold = marshal_data[:repro_threshold]
    lf.repro_num_offspring = marshal_data[:repro_num_offspring]
    lf.repro_energy_inherit_perc = marshal_data[:repro_energy_inherit_perc]
    lf.save
    lf
  end


  let(:tol) { 0.0001 }
  let(:species) { Species.new(name: "Test Lifeform").save }
  let(:env_energy) { 10.0 }
  let(:env) { Environment.new(width: 100, height: 100, time_step: 2, energy_rate: env_energy).save }
  let(:marshal_data) {{
    :energy_absorb_perc => 0.5, 
    :energy_base => 1.2, 
    :energy_reserve_perc => 0.6, 
    :repro_energy_inherit_perc => 0.8, 
    :repro_num_offspring => 3, 
    :repro_threshold => 20.0
  }}
  let(:lf) {
    add_lf(9.9, 7.7, 1.0, 10.0).save
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
      expect(lf.energy_base).to eq(marshal_data[:energy_base])
      expect(lf.energy_reserve_perc).to eq(marshal_data[:energy_reserve_perc])
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

  context ".metabolic_energy" do
    it "computes metabolic energy" do
      lf.energy_base = 5.0
      lf.size = 2.0
      # e_base * (size ** @exp)
      exp = 5.0 * (2.0 ** 3.0)
      expect(lf.metabolic_energy).to be_within(tol).of(exp)
    end    
  end

  context ".offspring_energy_*" do
    it "inherits all" do
      lf.repro_energy_inherit_perc = 1.0
      lf.energy = 100.0
      lf.repro_num_offspring = 1
      expect(lf.offspring_energy_tot).to be_within(tol).of(100.0)
      lf.repro_num_offspring = 4
      expect(lf.offspring_energy_each).to be_within(tol).of(25.0)
    end

    it "inherits none" do
      lf.repro_energy_inherit_perc = 0.0
      lf.energy = 100.0
      lf.repro_num_offspring = 1
      expect(lf.offspring_energy_tot).to be_within(tol).of(0.0)
      lf.repro_num_offspring = 4
      expect(lf.offspring_energy_each).to be_within(tol).of(0.0)
    end
  
    it "inherits half" do
      lf.repro_energy_inherit_perc = 0.5
      lf.energy = 100.0
      lf.repro_num_offspring = 1
      expect(lf.offspring_energy_tot).to be_within(tol).of(50.0)
      lf.repro_num_offspring = 4
      expect(lf.offspring_energy_each).to be_within(tol).of(12.5)
    end
  end

  context ".reproduce" do
    # we have separate tests for Reproduce so here we just need to test that
    # the resultant energy is correct
  
    [1, 4].each do |num_offspring|
      it "inherits all" do
        lf.repro_energy_inherit_perc = 1.0
        lf.energy = 100.0
        lf.repro_num_offspring = num_offspring
        lf.reproduce
        expect(lf.energy).to be_within(tol).of(0.0)
      end
    end

    [1, 4].each do |num_offspring|
      it "inherits none" do
        lf.repro_energy_inherit_perc = 0.0
        lf.energy = 100.0
        lf.repro_num_offspring = num_offspring
        lf.reproduce
        expect(lf.energy).to be_within(tol).of(100.0)
      end
    end

    [1, 4].each do |num_offspring|
      it "inherits half" do
        lf.repro_energy_inherit_perc = 0.5
        lf.energy = 100.0
        lf.repro_num_offspring = num_offspring
        lf.reproduce
        expect(lf.energy).to be_within(tol).of(50.0)
      end
    end
  end

  context ".cull" do
    it "kills low size lifeforms" do
      expect(lf.died_step).to be_nil
      lf.size = 5.0
      lf.save
      lf.cull.save
      expect(lf.is_alive?).to be_truthy # not dead yet
      lf.size = 0.9 # < 1.0
      lf.cull.save
      expect(lf.died_step).to eq(env.time_step)
    end

    it "kills low energy lifeforms" do
      expect(lf.died_step).to be_nil
      lf.energy = 0.1
      lf.save
      lf.cull.save
      expect(lf.is_alive?).to be_truthy # not dead yet
      lf.energy = 0.0
      lf.cull.save
      expect(lf.is_dead?).to be_truthy
    end
  end

  context ".bounding_box" do
    def test_bb(x, y, size, exp_x0, exp_y0, exp_x1, exp_y1)
      lf = add_lf(x, y, size, 1.0)
      act_x0, act_y0, act_x1, act_y1 = lf.bounding_box
      expect(act_x0).to be_within(tol).of(exp_x0)
      expect(act_y0).to be_within(tol).of(exp_y0)
      expect(act_x1).to be_within(tol).of(exp_x1)
      expect(act_y1).to be_within(tol).of(exp_y1)
    end

    it "correct bounding box" do
      test_bb(1.0, 1.0, 1.0, 0.5, 0.5, 1.5, 1.5)
      test_bb(6.0, 4.0, 10.0, 1.0, -1.0, 11.0, 9.0)
    end
  end

  context ".find_[potential_]overlaps" do
    def test_pot_overlaps(lf, exp)
      po = lf.find_potential_overlaps
      expect(po.count).to eq(exp.count)

      ids_exp = exp.map{ |x| x.id }.sort
      ids_act = po.map{ |x| x.id }.sort
      expect(ids_act).to eq(ids_exp)
    end

    def test_overlaps(lf, exp)
      o = lf.find_overlaps
      expect(o.count).to eq(exp.count)

      ids_exp = exp.map{ |x| x.id }.sort
      ids_act = o.map{ |x| x.id }.sort
      expect(ids_act).to eq(ids_exp)
    end

    it "single lifeform" do
      lf0 = add_lf(10.0, 10.0, 1.0, 20.0)
      test_pot_overlaps(lf0, [])
      test_overlaps(lf0, [])
    end

    it "two lifeforms, no overlap" do
      lf0 = add_lf(0.0, 0.0, 1.0, 20.0)
      lf1 = add_lf(1.01, 1.01, 1.0, 20.0)
      test_pot_overlaps(lf0, [])
      test_pot_overlaps(lf1, [])
      test_overlaps(lf0, [])
      test_overlaps(lf1, [])
    end

    it "two lifeforms, potential overlap only" do
      lf0 = add_lf(0.0, 0.0, 1.0, 20.0)
      lf1 = add_lf(0.99, 0.99, 1.0, 20.0)
      test_pot_overlaps(lf0, [lf1])
      test_pot_overlaps(lf1, [lf0])
      test_overlaps(lf0, [])
      test_overlaps(lf1, [])
    end

    it "two lifeforms, partial horizontal overlap" do
      lf0 = add_lf(0.0, 0.0, 1.0, 20.0)
      lf1 = add_lf(0.99, 0.0, 1.0, 20.0)
      test_pot_overlaps(lf0, [lf1])
      test_pot_overlaps(lf1, [lf0])
      test_overlaps(lf0, [lf1])
      test_overlaps(lf1, [lf0])
    end

    it "two lifeforms, partial vertical overlap" do
      lf0 = add_lf(0.0, 0.0, 1.0, 20.0)
      lf1 = add_lf(0.0, 0.99, 1.0, 20.0)
      test_pot_overlaps(lf0, [lf1])
      test_pot_overlaps(lf1, [lf0])
      test_overlaps(lf0, [lf1])
      test_overlaps(lf1, [lf0])
    end

    it "two lifeforms, partial diagonal overlap" do
      lf0 = add_lf(0.0, 0.0, 1.0, 20.0)
      lf1 = add_lf(0.7, 0.7, 1.0, 20.0)
      test_pot_overlaps(lf0, [lf1])
      test_pot_overlaps(lf1, [lf0])
      test_overlaps(lf0, [lf1])
      test_overlaps(lf1, [lf0])
    end

    it "two lifeforms, full overlap (identical)" do
      lf0 = add_lf(0.7, 0.7, 1.0, 20.0)
      lf1 = add_lf(0.7, 0.7, 1.0, 20.0)
      test_pot_overlaps(lf0, [lf1])
      test_pot_overlaps(lf1, [lf0])
      test_overlaps(lf0, [lf1])
      test_overlaps(lf1, [lf0])
    end

    it "two lifeforms, containment" do
      lf0 = add_lf(0.7, 0.7, 1.0, 20.0)
      lf1 = add_lf(1.0, 1.0, 10.0, 20.0)
      test_pot_overlaps(lf0, [lf1])
      test_pot_overlaps(lf1, [lf0])
      test_overlaps(lf0, [lf1])
      test_overlaps(lf1, [lf0])
    end

    # Visualiation:
    # 0     1
    # 2  3
    # 4  5  6
    # This includes a mix of potential and actual overlaps. The given size
    # means the diagonal matches are potential and horiz/vert are actual.
    # Size would need to be >=1.415 to be actual for the diagonals.
    it "multiple lifeforms, potential overlap only" do
      size = 1.05
      lf0 = add_lf(0.0, 0.0, size, 20.0)
      lf1 = add_lf(2.0, 0.0, size, 20.0)
      lf2 = add_lf(0.0, 1.0, size, 20.0)
      lf3 = add_lf(1.0, 1.0, size, 20.0)
      lf4 = add_lf(0.0, 2.0, size, 20.0)
      lf5 = add_lf(1.0, 2.0, size, 20.0)
      lf6 = add_lf(2.0, 2.0, size, 20.0)
      test_pot_overlaps(lf0, [lf2, lf3])
      test_pot_overlaps(lf1, [lf3])
      test_pot_overlaps(lf2, [lf0, lf3, lf4, lf5])
      test_pot_overlaps(lf3, [lf0, lf1, lf2, lf4, lf5, lf6])
      test_pot_overlaps(lf4, [lf2, lf3, lf5])
      test_pot_overlaps(lf5, [lf4, lf2, lf3, lf6])
      test_pot_overlaps(lf6, [lf3, lf5])

      test_overlaps(lf0, [lf2])
      test_overlaps(lf1, [])
      test_overlaps(lf2, [lf0, lf3, lf4])
      test_overlaps(lf3, [lf2, lf5])
      test_overlaps(lf4, [lf2, lf5])
      test_overlaps(lf5, [lf4, lf3, lf6])
      test_overlaps(lf6, [lf5])
    end

    it "multiple lifeforms, actual overlaps" do
      size = 1.415
      lf0 = add_lf(0.0, 0.0, size, 20.0)
      lf1 = add_lf(2.0, 0.0, size, 20.0)
      lf2 = add_lf(0.0, 1.0, size, 20.0)
      lf3 = add_lf(1.0, 1.0, size, 20.0)
      lf4 = add_lf(0.0, 2.0, size, 20.0)
      lf5 = add_lf(1.0, 2.0, size, 20.0)
      lf6 = add_lf(2.0, 2.0, size, 20.0)
      test_pot_overlaps(lf0, [lf2, lf3])
      test_pot_overlaps(lf1, [lf3])
      test_pot_overlaps(lf2, [lf0, lf3, lf4, lf5])
      test_pot_overlaps(lf3, [lf0, lf1, lf2, lf4, lf5, lf6])
      test_pot_overlaps(lf4, [lf2, lf3, lf5])
      test_pot_overlaps(lf5, [lf4, lf2, lf3, lf6])
      test_pot_overlaps(lf6, [lf3, lf5])

      test_overlaps(lf0, [lf2, lf3])
      test_overlaps(lf1, [lf3])
      test_overlaps(lf2, [lf0, lf3, lf4, lf5])
      test_overlaps(lf3, [lf0, lf1, lf2, lf4, lf5, lf6])
      test_overlaps(lf4, [lf2, lf3, lf5])
      test_overlaps(lf5, [lf4, lf2, lf3, lf6])
      test_overlaps(lf6, [lf3, lf5])
    end

    # Then also increase size ot 1.415 to get all overlaps
  end

  context ".env_energy" do
    # env_energy_gross
    # energy_overlap_loss
    
    it "single lifeform" do
      lf = add_lf(10.0, 10.0, 1.0, 20.0)
      exp_egy = 7.853981633974483
      exp_loss = 0.0
      expect(lf.env_energy_gross).to be_within(tol).of(exp_egy)
      expect(lf.energy_overlap_loss).to be_within(tol).of(exp_loss)
      expect(lf.env_energy).to be_within(tol).of(exp_egy - exp_loss)
    end

    it "two lifeforms, no overlap" do
      lf0 = add_lf(10.0, 10.0, 1.0, 20.0)
      lf1 = add_lf(20.0, 10.0, 1.0, 20.0)

      exp_egy = 7.853981633974483
      exp_loss = 0.0

      expect(lf0.env_energy_gross).to be_within(tol).of(exp_egy)
      expect(lf0.energy_overlap_loss).to be_within(tol).of(exp_loss)
      expect(lf0.env_energy).to be_within(tol).of(exp_egy - exp_loss)      

      expect(lf1.env_energy_gross).to be_within(tol).of(exp_egy)
      expect(lf1.energy_overlap_loss).to be_within(tol).of(exp_loss)
      expect(lf1.env_energy).to be_within(tol).of(exp_egy - exp_loss)      
    end

    it "two lifeforms, overlap" do
      lf0 = add_lf(0.0, 0.0, 2.0, 20.0)
      lf1 = add_lf(1.0, 0.0, 2.0, 20.0)
      
      overlap_area = circle_area_intersect(0, 0, 1, 1, 0, 1)

      exp_egy = Math::PI * env_energy
      exp_loss = env_energy * overlap_area / 2.0

      expect(lf0.env_energy_gross).to be_within(tol).of(exp_egy)
      expect(lf0.energy_overlap_loss).to be_within(tol).of(exp_loss)
      expect(lf0.env_energy).to be_within(tol).of(exp_egy - exp_loss)    
      expect(lf0.env_energy_gross).to be >= 0.0  
      expect(lf0.energy_overlap_loss).to be >= 0.0  
      expect(lf0.env_energy).to be >= 0.0  

      expect(lf1.env_energy_gross).to be_within(tol).of(exp_egy)
      expect(lf1.energy_overlap_loss).to be_within(tol).of(exp_loss)
      expect(lf1.env_energy).to be_within(tol).of(exp_egy - exp_loss)      
      expect(lf1.env_energy_gross).to be >= 0.0  
      expect(lf1.energy_overlap_loss).to be >= 0.0  
      expect(lf1.env_energy).to be >= 0.0  
    end
  end

  it "many lifeforms with overlap" do
    lf0 = add_lf(0.0, 0.0, 2.0, 20.0)
    lf1 = add_lf(1.0, 0.0, 2.0, 20.0)
    lf2 = add_lf(0.5, 0.5, 2.0, 20.0)
    lf3 = add_lf(0.6, 0.6, 2.0, 20.0)
    lf4 = add_lf(0.4, 0.4, 2.0, 20.0)
    
    exp_egy = Math::PI * env_energy

    [lf0, lf1, lf2, lf3, lf4].each do |lf|
      expect(lf.env_energy_gross).to be_within(tol).of(exp_egy)
      expect(lf.energy_overlap_loss).to be >= 0.0  
      expect(lf.env_energy).to be_within(tol).of(0.0)
    end
  end

  context ".run_step" do
    # TODO implement
  end
end