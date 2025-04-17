# Lifeforms

Lifeforms is an artificial life simulation that explores the effect of self-modifying code and evolving parameters on the behavior and survival of virtual lifeforms.

The simulation consists of an environment and a population of any number of lifeforms. Currently two different lifeform types exist: plants and grazers. Plants absorb energy from the environment and grow in place. Grazers can move to and consume plants. Both plants and grazers have metabolic energy needs that they must fulfill or die. They also can both reproduce and create children. When reproduction happens, the parameters and programming of the lifeform are passed on to the child potentially with mutations.

## Demo
This animation shows the plants and grazers spawning, growing, and finding food.

## System Design

The frontend written in plain HTML5 and Javascript, leveraging [Konva.js](https://konvajs.org/) to render visually the lifeforms.

The backend consists of a [Sinatra](https://sinatrarb.com/) Ruby app and PostgreSQL persistance layer.

## App Design

### Lifeforms
Each Lifeform is defined by:
  * *Skills* Things it is capable of doing, such as absorbing energy from the environment, moving towards food, eating, growing, reproducing, and shrinking.
  * *Parameters* Numeric values associated with the Skills, such as how far the lifeform can move, how many offspring it produces, etc. These Parameters control the behavior of the Skills and also can change value as the Lifeform reproduces.
  * *Program* A set of instructions that the Lifeform will execute at each step of the simulation.

### Environment
The Environment is a container for any number of Lifeforms. It has dimensions (width x height) and an energy rate that the Plants use to absorb. 

### Simulation Execution
Simulations are executed in discreet _steps_. When we run a _step_ of the Environment it will, in turn, run a _step_ for each of the contained Lifeforms. A Lifeform's step consists of executing its Program


## Running

`bundle install`

`rackup` will launch the Puma/Rack/Sinatra stack for the web app

`guard` will launch the same but will auto-reload
