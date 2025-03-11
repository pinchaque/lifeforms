# Contains several helper functions to generate saved objects in the db useful
# for unit tests.
class TestFactory
  def self.species
    Species.new(name: "Test Lifeform").save
  end

  def self.env(width = 100, height = 100, time_step = 0, energy_rate = 5.0)
    Environment.new(width: width, height: height, time_step: time_step, energy_rate: energy_rate).save
  end

  def self.lifeform(e, s)
    l = Lifeform.new
    l.environment_id = e.id
    l.species_id = s.id
    l.created_step = e.time_step
    l.energy = 10.0
    l.size = 1.0
    l.initial_size = 0.2
    l.name = "Incredible Juniper"
    l.x = 2.22
    l.y = 3.33
    l.energy_base = 1.0
    l.energy_exp = 3.0
    l.mark_born
    l.save
    l
  end
end