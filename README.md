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

## Supported Solvers

The following MDP solvers support this interface:
* [Value Iteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl)
* [Monte Carlo Tree Search](https://github.com/JuliaPOMDP/MCTS.jl)

The following POMDP solvers support this interface:
* [QMDP](https://github.com/JuliaPOMDP/QMDP.jl)
* [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl)
* [POMCP](https://github.com/JuliaPOMDP/POMCP.jl)
* [DESPOT](https://github.com/JuliaPOMDP/DESPOT.jl)
* [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl)

To install a solver run the following command:
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
