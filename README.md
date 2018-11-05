# POMDPs

| **`Linux`** | **`Mac OS X`** | 
|-----------------|---------------------|
| [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPs.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPs.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPs.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPs.jl)|


[![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/latest)
[![Gitter](https://badges.gitter.im/JuliaPOMDP/Lobby.svg)](https://gitter.im/JuliaPOMDP/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

This package provides a core interface for working with [Markov decision processes (MDPs)](https://en.wikipedia.org/wiki/Markov_decision_process) and [partially observable Markov decision processes (POMDPs)](https://en.wikipedia.org/wiki/Partially_observable_Markov_decision_process). For examples, please see the [Gallery](https://github.com/JuliaPOMDP/POMDPGallery.jl).

Our goal is to provide a common programming vocabulary for:

1. Expressing problems as MDPs and POMDPs. 
2. Writing solver software.
3. Running simulations efficiently.

There are [nested interfaces for expressing and interacting with (PO)MDPs](http://juliapomdp.github.io/POMDPs.jl/latest/def_pomdp): When the *[explicit](http://juliapomdp.github.io/POMDPs.jl/latest/explicit)* interface is used, the transition and observation probabilities are explicitly defined using api [functions](http://juliapomdp.github.io/POMDPs.jl/latest/explicit/#functional-form-explicit-pomdp) or [tables](http://juliapomdp.github.io/POMDPs.jl/latest/explicit/#tabular-form-explicit-pomdp); when the *[generative](http://juliapomdp.github.io/POMDPs.jl/latest/generative)* interface is used, only a single step simulator (e.g. (s', o, r) = G(s,a)) needs to be defined.

For help, please post to the [Google group](https://groups.google.com/forum/#!forum/pomdps-users), or on [gitter](https://gitter.im/JuliaPOMDP). Check [releases](https://github.com/JuliaPOMDP/POMDPs.jl/releases) for information on changes.

POMDPs.jl and all packages in the JuliaPOMDP project are fully supported on Linux and OS X. Windows support is available for all native Julia packages*. 

## Installation
To install POMDPs.jl, run the following from the Julia REPL: 
```julia
Pkg.add("POMDPs")
```

To install supported JuliaPOMDP packages including various solvers, first run:
```julia
using POMDPs
POMDPs.add_registry()
```

This installs the JuliaPOMDP registry so that the Julia package manager can find all the available solvers and support packages.

To check available JuliaPOMDP packages, run:
```julia
using POMDPs
POMDPs.available()
```

To install a particular solver (say `SARSOP.jl`), having installed the Registry, run:
```julia
Pkg.add("SARSOP")
```


## Quick Start

To run a simple simulation of the classic [Tiger POMDP](https://www.cs.rutgers.edu/~mlittman/papers/aij98-pomdp.pdf) using a policy created by the QMDP solver.

```julia
using POMDPs, POMDPModels, POMDPSimulators, QMDP
pomdp = TigerPOMDP()

# initialize a solver and compute a policy
solver = QMDPSolver() # from QMDP
policy = solve(solver, pomdp)
belief_updater = updater(policy) # the default QMDP belief updater (discrete Bayesian filter)

# run a short simulation with the QMDP policy
history = simulate(HistoryRecorder(max_steps=10), pomdp, policy, belief_updater)

# look at what happened
for (s, b, a, o) in eachstep(history, "sbao")
    println("State was $s,")
    println("belief was $b,")
    println("action $a was taken,")
    println("and observation $o was received.\n")
end
println("Discounted reward was $(discounted_reward(history)).")
```

For more examples with visualization see [POMDPGallery.jl](https://github.com/JuliaPOMDP/POMDPGallery.jl).

## Tutorials

Several tutorials are hosted in the [POMDPExamples repository](https://github.com/JuliaPOMDP/POMDPExamples.jl).

## Documentation

Detailed documentation can be found [here](http://juliapomdp.github.io/POMDPs.jl/latest/).

[![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/latest)
[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/stable)


## Supported Packages

Many packages use the POMDPs.jl interface, including MDP and POMDP solvers, support tools, and extensions to the POMDPs.jl interface. 

#### Tools:

POMDPs.jl itself contains only the interface for communicating about problem definitions. Most of the functionality for interacting with problems is actually contained in several support tools packages:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [POMDPModelTools](https://github.com/JuliaPOMDP/POMDPModelTools.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPModelTools.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPModelTools.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMDPModelTools.jl/badge.svg?)](https://coveralls.io/github/JuliaPOMDP/POMDPModelTools.jl?) |
| [BeliefUpdaters](https://github.com/JuliaPOMDP/BeliefUpdaters.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/BeliefUpdaters.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/BeliefUpdaters.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/BeliefUpdaters.jl/badge.svg?)](https://coveralls.io/github/JuliaPOMDP/BeliefUpdaters.jl?) |
| [POMDPPolicies](https://github.com/JuliaPOMDP/POMDPPolicies.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPPolicies.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPPolicies.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMDPPolicies.jl/badge.svg?)](https://coveralls.io/github/JuliaPOMDP/POMDPPolicies.jl?) |
| [POMDPSimulators](https://github.com/JuliaPOMDP/POMDPSimulators.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPSimulators.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPSimulators.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMDPSimulators.jl/badge.svg?)](https://coveralls.io/github/JuliaPOMDP/POMDPSimulators.jl?) |
| [POMDPModels](https://github.com/JuliaPOMDP/POMDPModels.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPModels.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPModels.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMDPModels.jl/badge.svg?)](https://coveralls.io/github/JuliaPOMDP/POMDPModels.jl?) |
| [POMDPTesting](https://github.com/JuliaPOMDP/POMDPTesting.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPTesting.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPTesting.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMDPTesting.jl/badge.svg?)](https://coveralls.io/github/JuliaPOMDP/POMDPTesting.jl?) |
| [ParticleFilters](https://github.com/JuliaPOMDP/ParticleFilters.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/ParticleFilters.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/ParticleFilters.jl) | [![codecov.io](http://codecov.io/github/JuliaPOMDP/ParticleFilters.jl/coverage.svg?)](http://codecov.io/github/JuliaPOMDP/ParticleFilters.jl?) |
| [RLInterface](https://github.com/JuliaPOMDP/RLInterface.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/RLInterface.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/RLInterface.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/RLInterface.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/RLInterface.jl?branch=master)

#### MDP solvers:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [Value Iteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/DiscreteValueIteration.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/DiscreteValueIteration.jl)  | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/DiscreteValueIteration.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/DiscreteValueIteration.jl?branch=master) |
| [Local Approximation Value Iteration](https://github.com/JuliaPOMDP/LocalApproximationValueIteration.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/LocalApproximationValueIteration.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/LocalApproximationValueIteration.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/LocalApproximationValueIteration.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/LocalApproximationValueIteration.jl?branch=master)
| [Monte Carlo Tree Search](https://github.com/JuliaPOMDP/MCTS.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/MCTS.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/MCTS.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/MCTS.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/MCTS.jl?branch=master) |

#### POMDP solvers:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [QMDP](https://github.com/JuliaPOMDP/QMDP.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/QMDP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/QMDP.jl) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/QMDP.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/QMDP.jl)  |
| [FIB](https://github.com/JuliaPOMDP/FIB.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/FIB.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/FIB.jl) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/FIB.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/FIB.jl)  |
| [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl)* | [![Build Status](https://travis-ci.org/JuliaPOMDP/SARSOP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/SARSOP.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/SARSOP.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/SARSOP.jl?branch=master) |
| [BasicPOMCP](https://github.com/JuliaPOMDP/BasicPOMCP.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/BasicPOMCP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/BasicPOMCP.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/BasicPOMCP.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/BasicPOMCP.jl?branch=master) |
| [ARDESPOT](https://github.com/JuliaPOMDP/ARDESPOT.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/ARDESPOT.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/ARDESPOT.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/ARDESPOT.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/ARDESPOT.jl?branch=master) |
| [MCVI](https://github.com/JuliaPOMDP/MCVI.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/MCVI.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/MCVI.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/MCVI.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/MCVI.jl?branch=master) |
| [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl)* | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPSolve.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPSolve.jl) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/POMDPSolve.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/POMDPSolve.jl) |
| [POMCPOW](https://github.com/JuliaPOMDP/POMCPOW.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMCPOW.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMCPOW.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMCPOW.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/POMCPOW.jl?branch=master) |
| [AEMS](https://github.com/JuliaPOMDP/AEMS.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/AEMS.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/AEMS.jl) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/AEMS.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/AEMS.jl)  |

#### Reinforcement Learning:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [TabularTDLearning](https://github.com/JuliaPOMDP/TabularTDLearning.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/TabularTDLearning.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/TabularTDLearning.jl) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/TabularTDLearning.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaPOMDP/TabularTDLearning.jl?branch=master) |
| [DeepQLearning](https://github.com/JuliaPOMDP/DeepQLearning.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/DeepQLearning.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/DeepQLearning.jl) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/DeepQLearning.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaPOMDP/DeepQLearning.jl?branch=master) |

#### Packages Awaiting Update

These packages were written for POMDPs.jl in Julia 0.6 and have not been updated to 1.0 yet.

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [DESPOT](https://github.com/JuliaPOMDP/DESPOT.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/DESPOT.jl.svg?branch=master)](https://travis-ci.com/JuliaPOMDP/DESPOT.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/DESPOT.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/DESPOT.jl?branch=master) |
| [IncrementalPruning](https://github.com/JuliaPOMDP/IncrementalPruning.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/IncrementalPruning.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/IncrementalPruning.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/IncrementalPruning.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/IncrementalPruning.jl?branch=master)  |

### Performance Benchmarks:

|  **`Package`**   | 
|-------------------|
| [DESPOT](https://github.com/JuliaPOMDP/DESPOT.jl/blob/master/test/perflog.md) | 

*_These packages require non-Julia dependencies_

## Citing POMDPs

If POMDPs is useful in your research and you would like to acknowledge it, please cite this [paper](http://www.jmlr.org/papers/v18/16-300.html):

```
@article{egorov2017pomdps,
  author  = {Maxim Egorov and Zachary N. Sunberg and Edward Balaban and Tim A. Wheeler and Jayesh K. Gupta and Mykel J. Kochenderfer},
  title   = {{POMDP}s.jl: A Framework for Sequential Decision Making under Uncertainty},
  journal = {Journal of Machine Learning Research},
  year    = {2017},
  volume  = {18},
  number  = {26},
  pages   = {1-5},
  url     = {http://jmlr.org/papers/v18/16-300.html}
}
```
