#!/usr/bin/env ruby

require '../lib/config'

env = Environment.new(100, 100)
pf = PlantFactory.new

for i in 0..5 do 
  l = pf.gen
  l.x, l.y = rnd_loc
  env.add_lifeform(l)
end

puts(env.to_s)