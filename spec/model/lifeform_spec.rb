RSpec.configure do |config|
  config.around(:each) do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end

class TestLF < Lifeform
  attr_accessor :val1, :val2

  def marshal_to_h
    super.merge({
      val1: val1,
      val2: val2
    })
  end

  def marshal_from_h(h)
    @val1 = h[:val1]
    @val2 = h[:val2]
    super(h)
  end

  def to_s
    super + " val1:#{@val1} val2:#{@val2}"
  end
end

describe "Lifeform" do
  let(:tol) { 0.0001 }
  let(:species) { Species.new(name: "Test Lifeform").save }
  let(:env) { Environment.new(width: 100, height: 100, time_step: 0).save }
  let(:tlf) {
    l = TestLF.new
    l.val1 = "foo"
    l.val2 = 42
    l.environment_id = env.id
    l.species_id = species.id
    l.energy = 10.0
    l.size = 1.0
    l.name = "Incredible Juniper"
    l.save
  }
  let(:loc) {
    LifeformLoc.new(x: 9.9, y: 7.7, lifeform_id: tlf.id, environment_id: env.id).save
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
    it "no location" do
      expect(tlf.to_s).to eq("Test Lifeform Incredible Juniper energy:10.00 size:1.00 loc:(?, ?) val1:foo val2:42")
    end

    it "with location" do
      loc.save
      expect(tlf.to_s).to eq("Test Lifeform Incredible Juniper energy:10.00 size:1.00 loc:(9.90, 7.70) val1:foo val2:42")
    end
  end

  def print_db
    puts("\n--- environments ---")
    DB.fetch("select * from environments") do |row|
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
      loc.save

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
      loc.save

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
      loc.save

      # create new object copying from existing
      lf_act = TestLF.new
      lf_act.copy_from(tlf)

      expect(lf_act.environment_id).to eq(tlf.environment_id)
      expect(lf_act.species_id).to eq(tlf.species_id)
      expect(lf_act.parent_id).to be_nil
      expect(lf_act.energy).to be_within(tol).of(tlf.energy)
      expect(lf_act.size).to be_within(tol).of(tlf.size)
      expect(lf_act.name).to eq(tlf.name)

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
end