#!/usr/bin/env ruby

require '../lib/config'


sim = Simulation.new(100, 100)
pf = PlantFactory.new
for i in 0..5 do 
  sim.add_lifeform_rnd(pf.gen)
end




puts(sim.to_s)
for t in 0..10 do
  sim.run_step
  puts("-" * 72)
  puts(sim.to_s)
end
