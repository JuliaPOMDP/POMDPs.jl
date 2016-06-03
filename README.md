[![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPs.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPs.jl)

# POMDPs

This package provides a basic interface for working with partially observable Markov decision processes (POMDPs).

The goal is to provide a common programming vocabulary for researchers and students to use primarily for three tasks:

1. Expressing problems using the POMDP format. 
2. Writing solver software.
3. Running simulations efficiently.

For problems and solvers that only use a generative model (rather than explicit transition and observation distributions), see also [GenerativeModels.jl](https://github.com/JuliaPOMDP/GenerativeModels.jl).

## Installation
```julia
Pkg.add("POMDPs")
```

## Supported Packages

The following MDP solvers support this interface:
* [Value Iteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl) 
[![Build Status](https://travis-ci.org/JuliaPOMDP/DiscreteValueIteration.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/DiscreteValueIteration.jl) 
[![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/DiscreteValueIteration.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/DiscreteValueIteration.jl?branch=master)
* [Monte Carlo Tree Search](https://github.com/JuliaPOMDP/MCTS.jl) 
[![Build Status](https://travis-ci.org/JuliaPOMDP/MCTS.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/MCTS.jl)
[![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/MCTS.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/MCTS.jl?branch=master)

The following POMDP solvers support this interface:
* [QMDP](https://github.com/JuliaPOMDP/QMDP.jl)
[![Build Status](https://travis-ci.org/JuliaPOMDP/QMDP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/QMDP.jl)
[![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/QMDP.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/QMDP.jl)
* [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl)
[![Build Status](https://travis-ci.org/JuliaPOMDP/SARSOP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/SARSOP.jl)
[![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/SARSOP.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/SARSOP.jl?branch=master)
* [POMCP](https://github.com/JuliaPOMDP/POMCP.jl)
[![Build Status](https://travis-ci.org/JuliaPOMDP/POMCP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMCP.jl)
[![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMCP.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/POMCP.jl?branch=master)
* [DESPOT](https://github.com/JuliaPOMDP/DESPOT.jl)
[![Build Status](https://travis-ci.org/JuliaPOMDP/DESPOT.jl.svg?branch=master)](https://travis-ci.com/JuliaPOMDP/DESPOT.jl)
[![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/DESPOT.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/DESPOT.jl?branch=master)
* [MCVI](https://github.com/JuliaPOMDP/MCVI.jl)
[![Build Status](https://travis-ci.org/JuliaPOMDP/MCVI.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/MCVI.jl)
[![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/MCVI.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/MCVI.jl?branch=master)
* [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl)
[![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPSolve.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPSolve.jl)
[![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/POMDPSolve.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/POMDPSolve.jl)

The following support tools support this interface:
* [POMDPToolbox](https://github.com/JuliaPOMDP/POMDPToolbox.jl)
* [POMDPModels](https://github.com/JuliaPOMDP/POMDPModels.jl)
 
The following extensions support this interface:
* [GenerativeModels](https://github.com/JuliaPOMDP/GenerativeModels.jl)
* [POMDPBounds](https://github.com/JuliaPOMDP/POMDPBounds.jl)


To install a package run the following command:
```julia
using POMDPs
# the following command adds the SARSOP solver, you can add any supported solver this way
POMDPs.add("SARSOP") 
```

To install all the solvers, support tools and dependencies that are part of JuliaPOMDP run:
```julia
using POMDPs
POMDPs.add_all() # this may take a few minutes
```

## Tutorials

The following tutorials aim to get you up to speed with POMDPs.jl:
* [MDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/GridWorld.ipynb) for beginners
  gives an overview of using Value Iteration and Monte-Carlo Tree Search with the classic grid world problem
* [POMDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/Tiger.ipynb) gives an overview
  of using SARSOP and QMDP to solve the tiger problem


## Documentation

Detailed documentation can be found [here](http://juliapomdp.github.io/POMDPs.jl/latest/).
