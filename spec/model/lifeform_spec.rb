RSpec.configure do |config|
  # too verbose otherwise
  config.default_formatter = "progress"
end

describe "Lifeform" do
  let(:tol) { 0.0001 }
  let(:species) { TestFactory.species }
  let(:width) { 100 }
  let(:height) { 100 }
  let(:time_step) { 3 }
  let(:env) { TestFactory.env(width: width, height: height, time_step: time_step) }
  let(:lf) { TestFactory.lifeform(env, species) }

  def add_lf(x, y, size = 1.0, energy = 10.0)
    lf = Lifeform.new
    lf.environment_id = env.id
    lf.created_step = 1
    lf.species_id = species.id
    lf.energy = energy
    lf.size = size
    lf.initial_size = 0.2
    lf.x = x
    lf.y = y
    lf.name = sprintf("add_lf(%f, %f, %f, %f)", x, y, size, energy)
    lf.energy_base = 1.0
    lf.energy_exp = 3.0
    lf.save
    lf
  end

  context ".attrs" do
    it "returns attr hash" do
      lf.created_step = 1
      lf.save
      expect(env.time_step).to eq(3)
      attr_exp = {
        lf_age: 2,
        lf_energy: 10.0,
        lf_metabolic_energy: lf.metabolic_energy,
        lf_size: 1.0,
        lf_generation: 2,
        lf_initial_size: 0.2,
        lf_x: 2.22,
        lf_y: 3.33,
      }

      attr_act = lf.attrs
      cmp_hash_vals(attr_act, attr_exp, tol)
    end
  end

  context ".register_skill" do
    let(:obs_val) { 1.23 }
    let(:obs_id) { :test_obs_1 }
    it "registers skill" do
      LifeformTestObs1 = TestFactory.obs(obs_val)
      obs = {obs_id => LifeformTestObs1}
      LifeformTestSkill1 = TestFactory.skill("skill1", obs)

      expect(lf.skills.count).to eq(0)
      expect(lf.params.count).to eq(0)
      expect(lf.observations.count).to eq(0)
      lf.register_skill(LifeformTestSkill1)
      expect(lf.skills.count).to eq(1)
      expect(lf.params.count).to eq(2)
      expect(lf.observations.count).to eq(1)

      # make sure observation registered as expected
      expect(lf.context.value(obs_id)).to be_within(tol).of(obs_val)

      lf.clear_skills
      expect(lf.skills.count).to eq(0)
      expect(lf.params.count).to eq(0)
      expect(lf.observations.count).to eq(0)
    end
  end
  
  context ".objdata_to_h" do
    LifeformTestSkill2 = TestFactory.skill("skill1")

    let(:lf) { 
      l = TestFactory.lifeform(env, species)
      l.register_skill(LifeformTestSkill2)
      l.program = e_seq(e_true, e_skill(LifeformTestSkill2.id))
      l
    }

    it "converts data to hash" do
      exp = {
        skills: lf.skills.marshal,
        params: lf.params.marshal,
        program: lf.program.marshal
      }
      expect(lf.objdata_to_h).to eq(exp)
    end
  end

  context ".objdata_from_h" do
    it "populates object from hash" do
      lf_new = TestFactory.lifeform(env, species)

      # shouldn't have any of these yet
      expect(lf_new.skills.count).to eq(0)
      expect(lf_new.params.count).to eq(0)
      expect(lf_new.program.marshal).to eq(Expr::True.new.marshal)

      # reconstitute from our marshaled data
      h = lf.objdata_to_h
      lf_new.objdata_from_h(h)

      # should be the same objdata if we do it again
      expect(lf_new.objdata_to_h).to eq(h)
    end
  end

  context ".to_s" do
    it "with location" do
      expect(lf.to_s).to eq("#{lf.id} Test Lifeform #{lf.name} energy:10.00 size:1.00 loc:(2.22, 3.33)")
    end
  end

  context ".render_data" do
    it "renders correct hash" do
      lf.save
      h = lf.render_data
      expect(h[:id]).to eq(lf.id)
      expect(h[:species]).to eq(species.name)
      expect(h[:energy]).to be_within(tol).of(lf.energy)
      expect(h[:size]).to be_within(tol).of(lf.size)
      expect(h[:name]).to eq(lf.name)
      expect(h[:generation]).to eq(2)
      expect(h[:x]).to be_within(tol).of(lf.x)
      expect(h[:y]).to be_within(tol).of(lf.y)
    end
  end

  context ".save" do
    it "saves to database" do
      # make sure lifeform and location are saved
      lf.save

      # test the raw db contents
      ds = DB["select * from lifeforms where id = ?", lf.id]
      expect(ds.count).to eq(1)
      row = ds.first
      expect(row[:id]).to eq(lf.id)
      expect(row[:environment_id]).to eq(env.id)
      expect(row[:species_id]).to eq(species.id)
      expect(row[:parent_id]).to be_nil
      expect(row[:died_step]).to be_nil
      expect(row[:created_step]).to eq(3)
      expect(row[:energy]).to be_within(tol).of(lf.energy)
      expect(row[:size]).to be_within(tol).of(lf.size)
      expect(row[:name]).to eq(lf.name)
      expect(row[:generation]).to eq(2)
      expect(row[:obj_data]).to eq("{\"params\":[],\"skills\":[],\"program\":{\"c\":\"True\"}}")
    end

    it "can be loaded from the db" do
      # make sure lifeform and location are saved
      lf.save

      # should have only 1 record
      ds = Lifeform.where(id: lf.id)
      expect(ds.count).to eq(1)
      
      # retrieve it
      lf_act = ds.first

      # check Lifeform
      expect(lf_act.id).to eq(lf.id)
      expect(lf_act.environment_id).to eq(env.id)
      expect(lf_act.species_id).to eq(species.id)
      expect(lf_act.parent_id).to be_nil
      expect(lf_act.energy).to be_within(tol).of(lf.energy)
      expect(lf_act.size).to be_within(tol).of(lf.size)
      expect(lf_act.name).to eq(lf.name)
      expect(lf_act.generation).to eq(lf.generation)
      expect(lf_act.obj_data).to eq("{\"params\":[],\"skills\":[],\"program\":{\"c\":\"True\"}}")
    end
  end

  context ".create_child" do
    it "copies all attributes" do
      # no parent/child relationship yet
      expect(lf.parent).to be_nil
      expect(lf.children.count).to eq(0)

      lf_child = lf.create_child

      # these data should all be copied from the parent
      expect(lf_child.environment_id).to eq(lf.environment_id)
      expect(lf_child.species_id).to eq(lf.species_id)
      expect(lf_child.initial_size).to be_within(tol).of(lf.initial_size)
      expect(lf_child.x).to be_within(tol).of(lf.x)
      expect(lf_child.y).to be_within(tol).of(lf.y)
      expect(lf_child.energy_base).to be_within(tol).of(lf.energy_base)
      expect(lf_child.energy_exp).to be_within(tol).of(lf.energy_exp)
      expect(lf_child.params.marshal).to eq(lf.params.marshal)
      expect(lf_child.skills.marshal).to eq(lf.skills.marshal)
      expect(lf_child.program.marshal).to eq(lf.program.marshal)

      # these data are updated for new children
      expect(lf_child.parent_id).to eq(lf.id)
      expect(lf_child.created_step).to eq(env.time_step)
      expect(lf_child.size).to be_within(tol).of(lf.initial_size)
      expect(lf_child.energy).to be_within(tol).of(0.0)
      expect(lf_child.name).not_to eq(lf.name)
      expect(lf_child.name).not_to be_nil
      expect(lf_child.died_step).to be_nil
      expect(lf_child.generation).to eq(lf.generation + 1)

      # some data isn't set because it isn't saved yet
      expect(lf_child.id).to be_nil
      expect(lf_child.obj_data).to be_nil

      # save the new object
      lf_child.save

      # now we should have these set
      expect(lf_child.id).not_to be_nil
      expect(lf_child.obj_data).to eq("{\"params\":[],\"skills\":[],\"program\":{\"c\":\"True\"}}")

      # now validate the children and parent helpers
      parent_act = lf_child.parent
      expect(parent_act.id).to eq(lf.id)
      child_act = lf.children
      expect(child_act.count).to eq(1)
      expect(child_act[0].id).to eq(lf_child.id)
    end
  end

  context ".set_loc_random" do
    (0...1).each do 
      it "generates random coordinates within environment" do
        lf.set_loc_random
        expect(lf.x).to be_between(0.0, width).inclusive
        expect(lf.y).to be_between(0.0, height).inclusive
      end
    end
  end

  context ".set_loc_dist" do
    (0...100).each do 
      context "from center of canvas" do
        let(:other_x) { width / 2.0 }
        let(:other_y) { height / 2.0 }
        let(:dist) { [width / 2.0, height / 2.0].min }

        it "generates random coordinates within specified distance" do
          lf.set_loc_dist(other_x, other_y, dist)

          # should be within the env
          expect(lf.x).to be_between(0.0, width).inclusive
          expect(lf.y).to be_between(0.0, height).inclusive

          # should be "dist" away because distance is always within the 
          # canvas
          dist_act = Math.sqrt(((lf.x - other_x) ** 2) + ((lf.y - other_y) ** 2))
          expect(dist_act).to be_within(tol).of(dist)
        end
      end
    end

    (0...20).each do 
      context "other anywhere on canvas" do
        let(:other_x) { Random.rand(0.0..(width.to_f)) }
        let(:other_y) { Random.rand(0.0..(height.to_f)) }
        let(:dist) { [width / 1.5, height / 1.5].min }
        it "generates random coordinates within specified distance" do
          lf.set_loc_dist(other_x, other_y, dist)

          # should be within the env
          expect(lf.x).to be_between(0.0, width).inclusive
          expect(lf.y).to be_between(0.0, height).inclusive

          # should be no more than "dist" away
          dist_act = Math.sqrt(((lf.x - other_x) ** 2) + ((lf.y - other_y) ** 2))
          expect(dist_act - tol).to be <= dist

          # TODO can improve this test by checking that the coords are on the
          # env boundary if distance is short
        end
      end
    end
  end

  context ".mark_born" do
    it "sets created_step" do
      l = Lifeform.new
      l.environment_id = env.id
      expect(l.id).to be_nil
      expect(l.created_step).to be_nil
      expect(l.died_step).to be_nil
      expect(l.is_alive?).to be_truthy
      expect(l.is_dead?).to be_falsey
      l.mark_born
      expect(l.id).to be_nil
      expect(l.created_step).to eq(3)
      expect(l.died_step).to be_nil  
      expect(l.is_alive?).to be_truthy
      expect(l.is_dead?).to be_falsey
    end
  end

  context ".mark_dead" do
    it "sets died_step" do
      expect(lf.created_step).to eq(3)
      expect(lf.died_step).to be_nil
      expect(lf.is_alive?).to be_truthy
      expect(lf.is_dead?).to be_falsey
      env.time_step = 5
      env.save
      lf.mark_dead
      expect(lf.created_step).to eq(3)
      expect(lf.died_step).to eq(5)
      expect(lf.is_alive?).to be_falsey
      expect(lf.is_dead?).to be_truthy
    end
  end

  context ".radius" do
    it "computes radius" do
      [
        {size: 1.0, exp: 0.5},
        {size: 0.5, exp: 0.25},
        {size: 10.0, exp: 5.0},
      ].each do |h|
        lf.size = h[:size]
        expect(lf.radius).to be_within(tol).of(h[:exp])
      end      
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

  context ".set_random_name" do
    it "changes name" do
      old_name = lf.name
      lf.set_random_name
      expect(lf.name).not_to eq(old_name)
      expect(lf.name).not_to be_nil
    end
  end

  context ".context" do
    it "creates context for self" do
      ctx = lf.context
      expect(ctx.lifeform.id).to eq(lf.id)
      expect(ctx.env.id).to eq(env.id)
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

    # Then also increase size ot 1.415 to get all overlaps
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
  end

  context ".find_closest" do
    it "no other lifeforms" do
      lf = add_lf(1.0, 1.0)
      expect(lf.find_closest).to be_nil
    end

    it "one other lifeform" do
      lf = add_lf(1.0, 1.0)
      lf0 = add_lf(3.0, 3.0)
      expect(lf.find_closest.id).to eq(lf0.id)
    end

    it "several other lifeforms" do
      lf = add_lf(1.0, 1.0)
      add_lf(0, 13.1)
      add_lf(13.1, 0)
      lf0 = add_lf(3.0, 3.0)
      add_lf(3.1, 3.1)
      add_lf(13.1, 13.1)
      expect(lf.find_closest.id).to eq(lf0.id)
    end

    it "filters" do
      s0 = TestFactory.species("species 0")
      s1 = TestFactory.species("species 1")

      lf = add_lf(1.0, 1.0)

      lf0 = add_lf(3.0, 3.0)
      lf0.species_id = s0.id
      lf0.save

      lf1 = add_lf(3.1, 3.1)
      lf1.species_id = s1.id
      lf1.save

      lf2 = add_lf(13.1, 13.1)
      lf2.species_id = s0.id
      lf2.generation = 123
      lf2.save

      expect(lf.find_closest.id).to eq(lf0.id)
      expect(lf.find_closest(species_id: s0.id).id).to eq(lf0.id)
      expect(lf.find_closest(species_id: s1.id).id).to eq(lf1.id)
      expect(lf.find_closest(generation: 123).id).to eq(lf2.id)
    end
  end

  context ".find_within_dist" do
    def t(lf, dist, lfs_exp, **filters)
      lfs_act = lf.find_within_dist(dist, **filters)
      cmp_objects(lfs_act, lfs_exp)
    end

    it "no other lifeforms" do
      lf = add_lf(1.0, 1.0)
      t(lf, 100.0, [])
    end

    it "one other lifeform on x axis" do
      lf = add_lf(1.0, 1.0)
      lf0 = add_lf(3.0, 1.0)
      t(lf, 100.0, [lf0])
      t(lf, 2.001, [lf0])
      t(lf, 1.999, [])
    end

    it "one other lifeform diagonal" do
      lf = add_lf(1.0, 1.0)
      lf0 = add_lf(2.0, 2.0)
      # actual dist is 1.414...
      t(lf, 100.0, [lf0])
      t(lf, 1.5, [lf0])
      t(lf, 1.3, []) # tests bounding box and distance calc
      t(lf, 0.99, [])
    end

    it "several other lifeforms" do
      lf = add_lf(1.0, 1.0)
      lf0 = add_lf(1.0, 13.0)
      lf1 = add_lf(13.0, 1.0)
      lf2 = add_lf(3.0, 3.0) # dist 2.828...
      lf3 = add_lf(3.1, 3.1) # dist 2.969...
      lf4 = add_lf(13.0, 13.0) # dist 16.97...
      t(lf, 2.8, [])
      t(lf, 2.9, [lf2])
      t(lf, 3.0, [lf2, lf3])
      t(lf, 12.1, [lf0, lf1, lf2, lf3])
      t(lf, 17.0, [lf0, lf1, lf2, lf3, lf4])
    end

    it "filters" do
      s0 = TestFactory.species("species 0")
      s1 = TestFactory.species("species 1")

      lf = add_lf(1.0, 1.0)

      lf0 = add_lf(3.0, 3.0) # dist 2.828...
      lf0.species_id = s0.id
      lf0.save

      lf1 = add_lf(3.1, 3.1)
      lf1.species_id = s1.id
      lf1.save

      lf2 = add_lf(13.1, 13.1)
      lf2.species_id = s0.id
      lf2.generation = 123
      lf2.save

      t(lf, 100.0, [lf0, lf1, lf2]) # no filters
      t(lf, 100.0, [lf2], generation: 123)
      t(lf, 100.0, [lf0, lf2], species_id: s0.id)
      t(lf, 100.0, [lf1], species_id: s1.id)
      t(lf, 3.0, [lf0], species_id: s0.id)
    end
  end

  context ".run_step" do
    it "deducts metabolic energy" do
      meta_egy = lf.metabolic_energy
      egy_before = lf.energy
      expect(meta_egy).to eq(1.0)
      expect(egy_before).to eq(10.0)
      expect(lf.is_alive?).to be true

      lf.run_step
      expect(lf.energy).to be_within(tol).of(9.0)
      expect(lf.is_alive?).to be true
    end

    it "kills if run out of energy" do
      meta_egy = lf.metabolic_energy
      lf.energy = 0.9
      expect(meta_egy).to eq(1.0)
      expect(lf.is_alive?).to be true

      lf.run_step
      expect(lf.energy).to eq(0.0)
      expect(lf.is_alive?).to be false
    end
  end
end