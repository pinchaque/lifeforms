require '../lib/config'

RSpec.configure do |config|
  config.around(:each) do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end

class TestLF < Lifeform
  attr_accessor :val1, :val2

  def marshal_to_h
    h = super
    h[:val1] = val1
    h[:val2] = val2
    h
  end

  def marshal_from_h(h)
    @val1 = h[:val1]
    @val2 = h[:val2]
    super(h)
  end
end

describe "Lifeform" do
  let(:species) { Species.new(name: "Test Lifeform", class_name: "TestLF").save }
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
      expect(tlf.to_s).to eq("Test Lifeform Incredible Juniper energy:10.00 size:1.00 loc:(?, ?)")
    end

    it "with location" do
      loc.save
      expect(tlf.to_s).to eq("Test Lifeform Incredible Juniper energy:10.00 size:1.00 loc:(9.90, 7.70)")
    end
  end

  context ".save" do
    it "saves to database" do
      # make sure lifeform and location are saved
      tlf.save
      loc.save

      tlf_act = LifeForm.where(lifeform_id: tlf.id).first
      expect(tlf_act.id).to eq(tlf.id)
      expect()

      # TODO test with SQL that it's in the db
    end

    it "can be loaded from the db" do
      # TODO test we can read back out via the object
    end
  end
end