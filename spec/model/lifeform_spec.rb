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
  let(:env) { TestFactory.env(width, height, time_step) }
  let(:lf) { TestFactory.lifeform(env, species) }
  
  context ".marshal_to_h" do
    it "TODO - needs to be implemented" do
      expect(lf.marshal_to_h).to eq("")
    end
  end

  context ".marshal_from_h" do
    it "TODO - needs to be implemented" do
      lf = Lifeform.new
      lf.marshal_from_h({})
      expect(lf.val1).to eq("foo")
    end
  end

  context ".to_s" do
    it "with location" do
      expect(lf.to_s).to eq("#{lf.id} Test Lifeform Incredible Juniper energy:10.00 size:1.00 loc:(2.22, 3.33)")
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
      expect(h[:generation]).to eq(0)
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
      expect(row[:generation]).to eq(0)
      expect(row[:obj_data]).to eq("{\"val1\":\"foo\",\"val2\":42}")
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
      expect(lf_act.obj_data).to eq("{\"val1\":\"foo\",\"val2\":42}")
    end
  end

  context ".copy_from" do
    it "copies all attributes" do
      lf.save

      # create new object copying from existing
      lf_act = Lifeform.new
      lf_act.copy_from(lf)

      expect(lf_act.environment_id).to eq(lf.environment_id)
      expect(lf_act.species_id).to eq(lf.species_id)
      expect(lf_act.parent_id).to be_nil
      expect(lf_act.energy).to be_within(tol).of(lf.energy)
      expect(lf_act.size).to be_within(tol).of(lf.size)
      expect(lf_act.initial_size).to be_within(tol).of(lf.initial_size)
      expect(lf_act.name).to eq(lf.name)
      expect(lf_act.x).to be_within(tol).of(lf.x)
      expect(lf_act.y).to be_within(tol).of(lf.y)

      # some data isn't set because it isn't saved yet
      expect(lf_act.id).to be_nil
      expect(lf_act.class_name).to be_nil
      expect(lf_act.obj_data).to be_nil

      # created_step isn't copied and needs to be set manually
      expect(lf_act.created_step).to be_nil
      lf_act.created_step = 123 # pick a number so we can save

      # save the new object
      lf_act.save

      # now we should have these set
      expect(lf_act.obj_data).to eq("{\"val1\":\"foo\",\"val2\":42}")
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
end