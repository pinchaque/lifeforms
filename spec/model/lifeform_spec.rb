RSpec.configure do |config|
  # too verbose otherwise
  config.default_formatter = "progress"
end

describe "Lifeform" do
  let(:tol) { 0.0001 }
  let(:species) { Species.new(name: "Test Lifeform").save }
  let(:width) { 100 }
  let(:height) { 100 }
  let(:env) { Environment.new(width: width, height: height, time_step: 0).save }
  let(:tlf) {
    l = TestLF.new
    l.val1 = "foo"
    l.val2 = 42
    l.environment_id = env.id
    l.species_id = species.id
    l.energy = 10.0
    l.size = 1.0
    l.name = "Incredible Juniper"
    l.x = 2.22
    l.y = 3.33
    l.save
  }
  
  context ".marshal_to_h" do
    it "marshals string & int" do
      tlf = TestLF.new
      tlf.val1 = "foo"
      tlf.val2 = 42
      expect(tlf.marshal_to_h).to eq({val1: "foo", val2: 42})
    end
  end

  context ".marshal_from_h" do
    it "marshals string & int" do
      tlf = TestLF.new
      tlf.marshal_from_h({val1: "foo", val2: 42})
      expect(tlf.val1).to eq("foo")
      expect(tlf.val2).to eq(42)
    end
  end

  context ".to_s" do
    it "with location" do
      expect(tlf.to_s).to eq("Test Lifeform Incredible Juniper energy:10.00 size:1.00 loc:(2.22, 3.33) val1:foo val2:42")
    end
  end

  context ".render_data" do
    it "renders correct hash" do
      tlf.save
      h = tlf.render_data
      expect(h[:id]).to eq(tlf.id)
      expect(h[:species]).to eq(species.name)
      expect(h[:energy]).to be_within(tol).of(tlf.energy)
      expect(h[:size]).to be_within(tol).of(tlf.size)
      expect(h[:name]).to eq(tlf.name)
      expect(h[:generation]).to eq(0)
      expect(h[:x]).to be_within(tol).of(tlf.x)
      expect(h[:y]).to be_within(tol).of(tlf.y)
    end
  end

  def print_db
    puts("\n--- environments ---")
    DB.fetch("select * from environments") do |h|
      puts row
    end
    puts("\n--- lifeforms ---")
    DB.fetch("select * from lifeforms") do |row|
      puts row
    end
    puts("\n--- lifeform_locs ---")
    DB.fetch("select * from lifeform_locs") do |row|
      puts row
    end  
  end

  context ".save" do
    it "saves to database" do
      # make sure lifeform and location are saved
      tlf.save

      # test the raw db contents
      ds = DB["select * from lifeforms where id = ?", tlf.id]
      expect(ds.count).to eq(1)
      row = ds.first
      expect(row[:id]).to eq(tlf.id)
      expect(row[:environment_id]).to eq(env.id)
      expect(row[:species_id]).to eq(species.id)
      expect(row[:parent_id]).to be_nil
      expect(row[:class_name]).to eq("TestLF")
      expect(row[:energy]).to be_within(tol).of(tlf.energy)
      expect(row[:size]).to be_within(tol).of(tlf.size)
      expect(row[:name]).to eq(tlf.name)
      expect(row[:generation]).to eq(0)
      expect(row[:obj_data]).to eq("{\"val1\":\"foo\",\"val2\":42}")
    end

    it "can be loaded from the db" do
      # make sure lifeform and location are saved
      tlf.save

      # should have only 1 record
      ds = Lifeform.where(id: tlf.id)
      expect(ds.count).to eq(1)
      
      # retrieve it
      lf_act = ds.first

      # should have returned the subclass
      expect(lf_act.class.name).to eq("TestLF")

      # check Lifeform (parent class) data
      expect(lf_act.id).to eq(tlf.id)
      expect(lf_act.environment_id).to eq(env.id)
      expect(lf_act.species_id).to eq(species.id)
      expect(lf_act.parent_id).to be_nil
      expect(lf_act.class_name).to eq("TestLF")
      expect(lf_act.energy).to be_within(tol).of(tlf.energy)
      expect(lf_act.size).to be_within(tol).of(tlf.size)
      expect(lf_act.name).to eq(tlf.name)
      expect(lf_act.generation).to eq(tlf.generation)
      expect(lf_act.obj_data).to eq("{\"val1\":\"foo\",\"val2\":42}")

      # check TestLF (child class) data
      expect(lf_act.val1).to eq("foo")
      expect(lf_act.val2).to eq(42)
    end
  end

  context ".copy_from" do
    it "copies all attributes" do
      tlf.save

      # create new object copying from existing
      lf_act = TestLF.new
      lf_act.copy_from(tlf)

      expect(lf_act.environment_id).to eq(tlf.environment_id)
      expect(lf_act.species_id).to eq(tlf.species_id)
      expect(lf_act.parent_id).to be_nil
      expect(lf_act.energy).to be_within(tol).of(tlf.energy)
      expect(lf_act.size).to be_within(tol).of(tlf.size)
      expect(lf_act.name).to eq(tlf.name)
      expect(lf_act.x).to be_within(tol).of(tlf.x)
      expect(lf_act.y).to be_within(tol).of(tlf.y)

      # check TestLF (child class) data
      expect(lf_act.val1).to eq("foo")
      expect(lf_act.val2).to eq(42)

      # some data isn't set because it isn't saved yet
      expect(lf_act.id).to be_nil
      expect(lf_act.class_name).to be_nil
      expect(lf_act.obj_data).to be_nil

      # save the new object
      lf_act.save

      # now we should have these set
      expect(lf_act.class_name).to eq("TestLF")
      expect(lf_act.obj_data).to eq("{\"val1\":\"foo\",\"val2\":42}")
    end
  end

  context ".set_loc_random" do
    (0...1).each do 
      it "generates random coordinates within environment" do
        tlf.set_loc_random
        expect(tlf.x).to be_between(0.0, width).inclusive
        expect(tlf.y).to be_between(0.0, height).inclusive
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
          tlf.set_loc_dist(other_x, other_y, dist)

          # should be within the env
          expect(tlf.x).to be_between(0.0, width).inclusive
          expect(tlf.y).to be_between(0.0, height).inclusive

          # should be "dist" away because distance is always within the 
          # canvas
          dist_act = Math.sqrt(((tlf.x - other_x) ** 2) + ((tlf.y - other_y) ** 2))
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
          tlf.set_loc_dist(other_x, other_y, dist)

          # should be within the env
          expect(tlf.x).to be_between(0.0, width).inclusive
          expect(tlf.y).to be_between(0.0, height).inclusive

          # should be no more than "dist" away
          dist_act = Math.sqrt(((tlf.x - other_x) ** 2) + ((tlf.y - other_y) ** 2))
          expect(dist_act - tol).to be <= dist

          # TODO can improve this test by checking that the coords are on the
          # env boundary if distance is short
        end
      end
    end
  end
end