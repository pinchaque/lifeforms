#!/usr/bin/env ruby

require '../lib/config'

env = Environment.new(100, 100)
pf = PlantFactory.new

for i in 0..5 do 
  env.add_lifeform_rnd(pf.gen)
end

puts(env.to_s)