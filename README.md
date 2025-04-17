# Lifeforms

Lifeforms is an artificial life simulation that explores the effect of self-modifying code and evolving parameters on the behavior and survival of virtual lifeforms.

The simulation consists of an environment and a population of any number of lifeforms. Currently two different lifeform types exist: plants and grazers. Plants absorb energy from the environment and grow in place. Grazers can move to and consume plants. Both plants and grazers have metabolic energy needs that they must fulfill or die. They also can both reproduce and create children. When reproduction happens, the parameters and programming of the lifeform are passed on to the child potentially with mutations.

## Demo
This animation shows several dozen simulation steps in which the plants spawn and grow, and grazers move towards food.

![Animation of several dozen steps of a simulation.](/assets/lifeforms_demo.gif)

## App Design

### Simulation
A Simulation consists of an Environment and any number of Lifeforms. The Simulation then is executed in discreet _steps_.

When we run a _step_ of the Environment it will, in turn:
  1. Spawn new Lifeforms if we are below minimum thresholds, or randomly
  2. Run a _step_ for each of the contained Lifeforms

After each simulation step we capture statistics about the Lifeforms, such as how many are alive/dead and what their total energy is. In this way we can monitor the simulation.

### Environment
The Environment is a container for any number of Lifeforms. It has dimensions (width x height) and an energy rate that the Plants use to absorb. 

### Lifeforms
Each Lifeform is defined by:
  * *Skills* Things it is capable of doing, such as absorbing energy from the environment, moving towards food, eating, growing, reproducing, and shrinking.
  * *Parameters* Numeric values associated with the Skills, such as how far the lifeform can move, how many offspring it produces, etc. These Parameters control the behavior of the Skills and also can change value as the Lifeform reproduces.
  * *Program* A set of instructions that the Lifeform will execute at each step of the simulation.

## System Design

The frontend written in plain HTML5 and Javascript, leveraging [Konva.js](https://konvajs.org/) to render visually the lifeforms.

The backend consists of a [Sinatra](https://sinatrarb.com/) Ruby app, [Sequel](https://github.com/jeremyevans/sequel) ORM, and [PostgreSQL](https://www.postgresql.org/) persistance layer.

## Running

### Installation

 * Install a recent version of PostgreSQL (development was done using PostgreSQL 16.6)
 * Install all the required Ruby Gems by running `bundle install`
 * Create a database user and add the credentials to `config/database.yml` (use `config/database.yml.example` as a template)
 * Set up the database schema by running `rake db:all`

### Command Line
Creating and running simulations can be done from the command line using Rake tasks prefixed with `sim:`. For example:
  * `rake sim:create` to create a new simulation
  * `rake sim:run` to run a single step of that simulation
  * `rake sim:view` to view details of that simulation

### Web App
To launch the web app you can use either of these commands:
  * `rackup` will launch the Puma/Rack/Sinatra stack for the web app
  * `bundle exec guard` will launch the same but will auto-reload
You can then use the app at [localhost:9292](http://127.0.0.1:9292). From there you can create new simulations, visualize them, and run steps.

