# POMDPs

| **`Linux`** | **`Mac OS X`** | **`Windows`** |
|-----------------|---------------------|-------------------------|
| [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPs.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPs.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPs.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPs.jl)| [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPs.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPs.jl)|

[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/stable)
[![Dev-Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/latest)
[![Gitter](https://badges.gitter.im/JuliaPOMDP/Lobby.svg)](https://gitter.im/JuliaPOMDP/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Slack](https://img.shields.io/badge/Chat%20on%20Slack-with%20%23pomdp--bridged-ff69b4)](https://slackinvite.julialang.org)

This package provides a core interface for working with [Markov decision processes (MDPs)](https://en.wikipedia.org/wiki/Markov_decision_process) and [partially observable Markov decision processes (POMDPs)](https://en.wikipedia.org/wiki/Partially_observable_Markov_decision_process). For examples, please see [POMDPExamples](https://github.com/JuliaPOMDP/POMDPExamples.jl), [QuickPOMDPs](https://github.com/JuliaPOMDP/QuickPOMDPs.jl), and the [Gallery](https://github.com/JuliaPOMDP/POMDPGallery.jl).

Our goal is to provide a common programming vocabulary for:

1. Expressing problems as MDPs and POMDPs. 
2. Writing solver software.
3. Running simulations efficiently.

There are [nested interfaces for expressing and interacting with (PO)MDPs](http://juliapomdp.github.io/POMDPs.jl/stable/def_pomdp): When the *[explicit](http://juliapomdp.github.io/POMDPs.jl/stable/explicit)* interface is used, the transition and observation probabilities are explicitly defined using api [functions](http://juliapomdp.github.io/POMDPs.jl/stable/explicit/#functional-form-explicit-pomdp); when the *[generative](http://juliapomdp.github.io/POMDPs.jl/stable/generative)* interface is used, only a single step simulator (e.g. (s', o, r) = G(s,a)) needs to be defined. Problems may also be defined with probability [tables](http://juliapomdp.github.io/POMDPs.jl/stable/explicit/#tabular-form-explicit-pomdp), or with the simplified [QuickPOMDPs interfaces](https://github.com/JuliaPOMDP/QuickPOMDPs.jl).

**Python** can be used to define and solve MDPs and POMDPs via the QuickPOMDPs or tabular interfaces and [pyjulia](https://github.com/JuliaPy/pyjulia) (Example: [tiger.py](https://github.com/JuliaPOMDP/QuickPOMDPs.jl/blob/master/examples/tiger.py)).

For help, please post to the [Google group](https://groups.google.com/forum/#!forum/pomdps-users), or on [gitter](https://gitter.im/JuliaPOMDP). Check [releases](https://github.com/JuliaPOMDP/POMDPs.jl/releases) for information on changes. POMDPs.jl and all packages in the JuliaPOMDP project are fully supported on Linux and OS X. Windows is supported for all native solvers\*, and most non-native solvers should work, but may require additional configuration.

## Installation
To install POMDPs.jl, run the following from the Julia REPL: 
```julia
Pkg.add("POMDPs")
```

To install supported JuliaPOMDP packages including various solvers, first add the JuliaPOMDP registry:
```julia
using POMDPs
POMDPs.add_registry()
```

You can then list packages with `POMDPs.available()` and install a solver (say `SARSOP.jl`) with
```julia
Pkg.add("SARSOP")
```

## Quick Start

To run a simple simulation of the classic [Tiger POMDP](https://www.cs.rutgers.edu/~mlittman/papers/aij98-pomdp.pdf) using a policy created by the QMDP solver, you can use the following code (Note that this uses the simplified [QuickPOMDPs interface](https://github.com/JuliaPOMDP/QuickPOMDPs.jl); the [main interface](https://juliapomdp.github.io/POMDPs.jl/stable/def_pomdp/) has much more expressive power):

```julia
using POMDPs, QuickPOMDPs, POMDPSimulators, QMDP

S = [:left, :right]
A = [:left, :right, :listen]
O = [:left, :right]
γ = 0.95

function T(s, a, sp)
    if a == :listen
        return s == sp
    else # a door is opened
        return 0.5 #reset
    end
end

function Z(a, sp, o)
    if a == :listen
        if o == sp
            return 0.85
        else
            return 0.15
        end
    else
        return 0.5
    end
end

function R(s, a)
    if a == :listen  
        return -1.0
    elseif s == a # the tiger was found
        return -100.0
    else # the tiger was escaped
        return 10.0
    end
end

m = DiscreteExplicitPOMDP(S,A,O,T,Z,R,γ)

solver = QMDPSolver()
policy = solve(solver, m)

rsum = 0.0
for (s,b,a,o,r) in stepthrough(m, policy, "s,b,a,o,r", max_steps=10)
    println("s: $s, b: $([pdf(b,s) for s in S]), a: $a, o: $o")
    global rsum += r
end
println("Undiscounted reward was $rsum.")
```

For more examples with visualization see [POMDPGallery.jl](https://github.com/JuliaPOMDP/POMDPGallery.jl).

## Tutorials

Several tutorials are hosted in the [POMDPExamples repository](https://github.com/JuliaPOMDP/POMDPExamples.jl).

## Documentation

Detailed documentation can be found [here](http://juliapomdp.github.io/POMDPs.jl/stable/).

[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/stable)
[![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/latest)


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

|  **`Package`**   |  **`Build/Coverage`** | Online/<br>Offline | Continuous<br>States | Continuous<br>Actions |
|-------------------|----------------------|----------------------|-------------------------|--|
| [Value Iteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/DiscreteValueIteration.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/DiscreteValueIteration.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/DiscreteValueIteration.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/DiscreteValueIteration.jl?branch=master) | Offline | N | N |
| [Local Approximation Value Iteration](https://github.com/JuliaPOMDP/LocalApproximationValueIteration.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/LocalApproximationValueIteration.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/LocalApproximationValueIteration.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/LocalApproximationValueIteration.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/LocalApproximationValueIteration.jl?branch=master) | Offline | Y | N |
| [Global Approximation Value Iteration](https://github.com/JuliaPOMDP/GlobalApproximationValueIteration.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/GlobalApproximationValueIteration.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/GlobalApproximationValueIteration.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/GlobalApproximationValueIteration.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/GlobalApproximationValueIteration.jl?branch=master) | Offline | Y | N |
| [Monte Carlo Tree Search](https://github.com/JuliaPOMDP/MCTS.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/MCTS.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/MCTS.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/MCTS.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/MCTS.jl?branch=master) | Online | Y (DPW) | Y (DPW) |

#### POMDP solvers:

|  **`Package`**   |  **`Build/Coverage`** | Online/<br>Offline | Continuous<br>States | Continuous<br>Actions | Continuous<br>Observations |
|-------------------|----------------------|----------------------|-------------------------|--|--|
| [QMDP](https://github.com/JuliaPOMDP/QMDP.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/QMDP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/QMDP.jl) <br> [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/QMDP.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/QMDP.jl)  | Offline | N | N | N |
| [FIB](https://github.com/JuliaPOMDP/FIB.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/FIB.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/FIB.jl) <br> [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/FIB.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/FIB.jl)  | Offline | N | N | N |
| [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl)* | [![Build Status](https://travis-ci.org/JuliaPOMDP/SARSOP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/SARSOP.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/SARSOP.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/SARSOP.jl?branch=master) | Offline | N | N | N |
| [BasicPOMCP](https://github.com/JuliaPOMDP/BasicPOMCP.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/BasicPOMCP.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/BasicPOMCP.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/BasicPOMCP.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/BasicPOMCP.jl?branch=master) | Online | Y | N | N<sup>1</sup> |
| [ARDESPOT](https://github.com/JuliaPOMDP/ARDESPOT.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/ARDESPOT.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/ARDESPOT.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/ARDESPOT.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/ARDESPOT.jl?branch=master) | Online | Y | N | N<sup>1</sup> |
| [MCVI](https://github.com/JuliaPOMDP/MCVI.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/MCVI.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/MCVI.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/MCVI.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/MCVI.jl?branch=master) | Offline | Y | N | Y |
| [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl)* | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPSolve.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPSolve.jl) <br> [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/POMDPSolve.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/POMDPSolve.jl) | Offline | N | N | N |
| [IncrementalPruning](https://github.com/JuliaPOMDP/IncrementalPruning.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/IncrementalPruning.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/IncrementalPruning.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/IncrementalPruning.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/IncrementalPruning.jl?branch=master)  | Offline | N | N | N |
| [POMCPOW](https://github.com/JuliaPOMDP/POMCPOW.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/POMCPOW.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMCPOW.jl) <br> [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/POMCPOW.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/POMCPOW.jl?branch=master) | Online | Y | Y<sup>2</sup> | Y |
| [AEMS](https://github.com/JuliaPOMDP/AEMS.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/AEMS.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/AEMS.jl) <br> [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/AEMS.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/AEMS.jl) | Online | N | N | N |

<sup>1</sup>: Will run, but will not converge to optimal solution

<sup>2</sup>: Will run, but convergence to optimal solution is not proven, and it will likely not work well on multidimensional action spaces

#### Reinforcement Learning:

|  **`Package`**   |  **`Build/Coverage`**  | Continuous<br>States | Continuous<br>Actions |
|-------------------|----------------------|------------------|------------------|
| [TabularTDLearning](https://github.com/JuliaPOMDP/TabularTDLearning.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/TabularTDLearning.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/TabularTDLearning.jl) <br> [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/TabularTDLearning.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaPOMDP/TabularTDLearning.jl?branch=master) | N | N |
| [DeepQLearning](https://github.com/JuliaPOMDP/DeepQLearning.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/DeepQLearning.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/DeepQLearning.jl) <br> [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/DeepQLearning.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaPOMDP/DeepQLearning.jl?branch=master) | Y<sup>1</sup> | N |

<sup>1</sup>: For POMDPs, it will use the observation instead of the state as input to the policy. See [RLInterface.jl](https://github.com/JuliaPOMDP/RLInterface.jl) for more details.

#### Packages Awaiting Update

These packages were written for POMDPs.jl in Julia 0.6 and have not been updated to 1.0 yet.

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [DESPOT](https://github.com/JuliaPOMDP/DESPOT.jl) | [![Build Status](https://travis-ci.org/JuliaPOMDP/DESPOT.jl.svg?branch=master)](https://travis-ci.com/JuliaPOMDP/DESPOT.jl) | [![Coverage Status](https://coveralls.io/repos/github/JuliaPOMDP/DESPOT.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaPOMDP/DESPOT.jl?branch=master) |

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
