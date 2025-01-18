#!/usr/bin/env ruby

require '../lib/config'

env = Environment.new(100, 100)

for i in 0..5 do 
  env.add_lifeform(Plant.new)
end

puts(env.to_s)