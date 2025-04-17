# Lifeforms

Lifeforms is an artificial life simulation that explores the effect of self-modifying code and evolving parameters on the behavior and survival of virtual lifeforms.

The simulation consists of an environment and a population of any number of lifeforms. Currently two different lifeform types exist: plants and grazers. Plants absorb energy from the environment and grow in place. Grazers can move to and consume plants. Both plants and grazers have metabolic energy needs that they must fulfill or die. They also can both reproduce and create children. When reproduction happens, the parameters and programming of the lifeform are passed on to the child potentially with mutations.

## System Design

The frontend of the system is written in plain Javascript and uses Konva.js to 

## App Design

## Running

`bundle install`

`rackup` will launch the Puma/Rack/Sinatra stack for the web app

`guard` will launch the same but will auto-reload