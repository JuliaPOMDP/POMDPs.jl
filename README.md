# POMDPs

[![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPs.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPs.jl)
[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/stable)

This package provides a core interface for working with Markov decision processes (MDPs) and partially observable Markov decision processes (POMDPs).

Our goal is to provide a common programming vocabulary for:

1. Expressing problems using the POMDP format. 
2. Writing solver software.
3. Running simulations efficiently.

For problems and solvers that only use a generative model (rather than explicit transition and observation distributions), see [GenerativeModels.jl](https://github.com/JuliaPOMDP/GenerativeModels.jl).

## Installation
To install POMDPs.jl, run the following from the Julia REPL: 
```julia
Pkg.add("POMDPs")
```

To install a specific supported JuliaPOMDP package run:
```julia
using POMDPs
# the following command installs the SARSOP solver, you can add any supported solver this way
POMDPs.add("SARSOP") 
```

To install all solvers, support tools, and dependencies that are part of JuliaPOMDP, run:
```julia
using POMDPs
POMDPs.add_all() # this may take a few minutes
```

To only install native solvers, without any non-Julia dependecies, run:
```julia
using POMDPs
POMDPs.add_all(native_only=true)
```

## Quick Start

Start the Julia REPL and run the following:
```julia
using POMDPs
using POMDPModels, POMDPToolbox, QMDP
# initialize problem and solver
pomdp = TigerPOMDP() # from POMDPModels
solver = QMDPSolver() # from QMDP
# compute a policy
policy = solve(solver, pomdp)
#evaluate the policy
belief_updater = updater(policy) # the default QMPD belief updater (discrete Bayesian filter)
init_dist = initial_state_distribution(pomdp) # from POMDPModels
# evaluate the policy
r = simulate(HistoryRecorder(max_steps=100), pomdp, policy, belief_updater, init_dist) # run 100 step simulation
```
The code above solves the Tiger POMDP using the QMDP algorithm, and evaluates its performance. 


## Tutorials

The following tutorials aim to get you up to speed with POMDPs.jl:
* [MDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/GridWorld.ipynb) for beginners
gives an overview of using Value Iteration and Monte-Carlo Tree Search with the classic grid world problem
* [POMDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/Tiger.ipynb) gives an overview
of using SARSOP and QMDP to solve the tiger problem


## Documentation

Detailed documentation can be found [here](http://juliapomdp.github.io/POMDPs.jl/latest/).

[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/stable)


## Supported Packages

Many packages use the POMDPs.jl interface, including MDP and POMDP solvers, support tools, and extensions to the POMDPs.jl interface. 

#### MDP solvers:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [Value Iteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/DiscreteValueIteration.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/DiscreteValueIteration.jl)  | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/DiscreteValueIteration.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/DiscreteValueIteration.jl?branch=master) |
| [Monte Carlo Tree Search](https://github.com/JuliaPOMDP/MCTS.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/MCTS.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/MCTS.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/MCTS.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/MCTS.jl?branch=master) |

#### POMDP solvers:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [QMDP](https://github.com/JuliaPOMDP/QMDP.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/QMDP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/QMDP.jl) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/QMDP.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/QMDP.jl)  |
| [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/SARSOP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/SARSOP.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/SARSOP.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/SARSOP.jl?branch=master) |
| [POMCP](https://github.com/JuliaPOMDP/POMCP.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMCP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMCP.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMCP.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/POMCP.jl?branch=master) |
| [DESPOT](https://github.com/JuliaPOMDP/DESPOT.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/DESPOT.jl.svg?branch=master)](https://travis-ci.com/JuliaPOMDP/DESPOT.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/DESPOT.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/DESPOT.jl?branch=master) |
| [MCVI](https://github.com/JuliaPOMDP/MCVI.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/MCVI.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/MCVI.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/MCVI.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/MCVI.jl?branch=master) |
| [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPSolve.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPSolve.jl) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/POMDPSolve.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/POMDPSolve.jl) |



#### Support Tools:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [POMDPToolbox](https://github.com/JuliaPOMDP/POMDPToolbox.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPToolbox.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPToolbox.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMDPToolbox.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/POMDPToolbox.jl?branch=master) |
| [POMDPModels](https://github.com/JuliaPOMDP/POMDPModels.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPModels.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPModels.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMDPModels.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/POMDPModels.jl?branch=master) |
 
#### Interface Extensions:

|  **`Package`**   |  **`Build`** |
|-------------------|----------------------|
| [GenerativeModels](https://github.com/JuliaPOMDP/GenerativeModels.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/GenerativeModels.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/GenerativeModels.jl) | 
| [POMDPBounds](https://github.com/JuliaPOMDP/POMDPBounds.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPBounds.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPBounds.jl) | 

