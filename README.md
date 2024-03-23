# POMDPs

| **`Linux`** | **`Mac OS X`** | **`Windows`** |
|-----------------|---------------------|-------------------------|
| [![Build Status](https://github.com/JuliaPOMDP/POMDPs.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/POMDPs.jl/actions/workflows/CI.yml) | [![Build Status](https://github.com/JuliaPOMDP/POMDPs.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/POMDPs.jl/actions/workflows/CI.yml)| [![Build Status](https://github.com/JuliaPOMDP/POMDPs.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/POMDPs.jl/actions/workflows/CI.yml)|

[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/stable)
[![Dev-Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/latest)
[![Gitter](https://badges.gitter.im/JuliaPOMDP/Lobby.svg)](https://gitter.im/JuliaPOMDP/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Slack](https://img.shields.io/badge/Chat%20on%20Slack-with%20%23pomdp--bridged-ff69b4)](https://julialang.org/slack/)

This package provides a core interface for working with [Markov decision processes (MDPs)](https://en.wikipedia.org/wiki/Markov_decision_process) and [partially observable Markov decision processes (POMDPs)](https://en.wikipedia.org/wiki/Partially_observable_Markov_decision_process).
The [POMDPTools](https://juliapomdp.github.io/POMDPs.jl/stable/POMDPTools/#pomdptools_section) package acts as a "standard library" for the POMDPs.jl interface, providing implementations of commonly-used components such as policies, belief updaters, distributions, and simulators.

Our goal is to provide a common programming vocabulary for:

1. [Expressing problems as MDPs and POMDPs](http://juliapomdp.github.io/POMDPs.jl/stable/def_pomdp). 
2. Writing solver software.
3. Running simulations efficiently.

POMDPs.jl integrates with other ecosystems:

- Python can be used to define and solve MDPs and POMDPs via the [quickpomdps](https://github.com/JuliaPOMDP/quickpomdps) package or through tables directly via [pyjulia](https://github.com/JuliaPy/pyjulia).
- POMDPTools provides [two-way integration](https://juliapomdp.github.io/POMDPModelTools.jl/stable/common_rl/#CommonRLInterface-Integration) with [CommonRLInterface](https://github.com/JuliaReinforcementLearning/CommonRLInterface.jl) and therefore with the [JuliaReinforcementLearning packages](https://github.com/JuliaReinforcementLearning/ReinforcementLearning.jl).
- The [SymbolicMDPs package](https://github.com/JuliaPlanners/SymbolicMDPs.jl) provides an interface to work with PDDL models.

For a detailed introduction, check out our [Julia Academy course](https://juliaacademy.com/p/decision-making-under-uncertainty-with-pomdps-jl)! For help, please post in [GitHub Discussions tab](https://github.com/JuliaPOMDP/POMDPs.jl/discussions). We welcome contributions from anyone! See [CONTRIBUTING.md](/CONTRIBUTING.md) for information about contributing.

## Installation

POMDPs.jl and associated solver packages can be installed using [Julia's package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/). For example, to install POMDPs.jl and the QMDP solver package, type the following in the Julia REPL:
```julia
using Pkg; Pkg.add("POMDPs"); Pkg.add("QMDP")
```

## Quick Start

To run a simple simulation of the classic [Tiger POMDP](https://people.csail.mit.edu/lpk/papers/aij98-pomdp.pdf) using a policy created by the QMDP solver, you can use the following code (note that POMDPs.jl is not limited to discrete problems with explicitly-defined distributions like this):

```julia
using POMDPs, QuickPOMDPs, POMDPTools, QMDP

m = QuickPOMDP(
    states = ["left", "right"],
    actions = ["left", "right", "listen"],
    observations = ["left", "right"],
    initialstate = Uniform(["left", "right"]),
    discount = 0.95,

    transition = function (s, a)
        if a == "listen"
            return Deterministic(s) # tiger stays behind the same door
        else # a door is opened
            return Uniform(["left", "right"]) # reset
        end
    end,

    observation = function (s, a, sp)
        if a == "listen"
            if sp == "left"
                return SparseCat(["left", "right"], [0.85, 0.15]) # sparse categorical distribution
            else
                return SparseCat(["right", "left"], [0.85, 0.15])
            end
        else
            return Uniform(["left", "right"])
        end
    end,

    reward = function (s, a)
        if a == "listen"
            return -1.0
        elseif s == a # the tiger was found
            return -100.0
        else # the tiger was escaped
            return 10.0
        end
    end
)

solver = QMDPSolver()
policy = solve(solver, m)

rsum = 0.0
for (s,b,a,o,r) in stepthrough(m, policy, "s,b,a,o,r", max_steps=10)
    println("s: $s, b: $([s=>pdf(b,s) for s in states(m)]), a: $a, o: $o")
    global rsum += r
end
println("Undiscounted reward was $rsum.")
```

For more examples and examples with visualizations, reference the [Examples](https://JuliaPOMDP.github.io/POMDPs.jl/latest/examples) and [Gallery of POMDPs.jl Problems](https://JuliaPOMDP.github.io/POMDPs.jl/latest/gallery) sections of the documentaiton.

## Documentation and Tutorials

In addition to the above-mentioned [Julia Academy course](https://juliaacademy.com/p/decision-making-under-uncertainty-with-pomdps-jl), detailed documentation and examples can be found [here](http://juliapomdp.github.io/POMDPs.jl/stable/).

[![Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/stable)
[![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://JuliaPOMDP.github.io/POMDPs.jl/latest)


## Supported Packages

Many packages use the POMDPs.jl interface, including MDP and POMDP solvers, support tools, and extensions to the POMDPs.jl interface. POMDPs.jl and all packages in the JuliaPOMDP project are fully supported on Linux. OSX and Windows are supported for all native solvers\*, and most non-native solvers should work, but may require additional configuration.

#### Tools:

POMDPs.jl itself contains only the core interface for communicating about problem definitions; these packages contain implementations of commonly-used components:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [POMDPTools](https://github.com/JuliaPOMDP/POMDPs.jl/tree/master/lib/POMDPTools) (hosted in this repository) | [![Build Status](https://github.com/JuliaPOMDP/POMDPs.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/POMDPs.jl/actions/workflows/CI.yml) | |
| [ParticleFilters](https://github.com/JuliaPOMDP/ParticleFilters.jl) | [![Build Status](https://github.com/JuliaPOMDP/ParticleFilters.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/ParticleFilters.jl) | [![codecov.io](http://codecov.io/github/JuliaPOMDP/ParticleFilters.jl/coverage.svg?)](http://codecov.io/github/JuliaPOMDP/ParticleFilters.jl?) |

#### Implemented Models:

Many models have been implemented using the POMDPs.jl interface for various projects. This list contains a few commonly used models:

|  **`Package`**   |  **`Build`** | **`Coverage`** |
|-------------------|----------------------|------------------|
| [POMDPModels](https://github.com/JuliaPOMDP/POMDPModels.jl) |[![CI](https://github.com/JuliaPOMDP/POMDPModels.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/POMDPModels.jl/actions/workflows/CI.yml)| [![codecov](https://codecov.io/gh/JuliaPOMDP/POMDPModels.jl/branch/master/graph/badge.svg?token=xPLiTP3IVt)](https://codecov.io/gh/JuliaPOMDP/POMDPModels.jl) |
| [LaserTag](https://github.com/JuliaPOMDP/LaserTag.jl) | [![CI](https://github.com/JuliaPOMDP/LaserTag.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/LaserTag.jl/actions/workflows/CI.yml) | [![codecov](https://codecov.io/gh/JuliaPOMDP/LaserTag.jl/branch/master/graph/badge.svg?token=Jo3cSe9K15)](https://codecov.io/gh/JuliaPOMDP/LaserTag.jl) |
| [RockSample](https://github.com/JuliaPOMDP/RockSample.jl) | [![CI](https://github.com/JuliaPOMDP/RockSample.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/RockSample.jl/actions/workflows/CI.yml) | [![codecov](https://codecov.io/github/JuliaPOMDP/RockSample.jl/branch/master/graph/badge.svg?token=EfDZPMisVB)](https://codecov.io/github/JuliaPOMDP/RockSample.jl) |
| [TagPOMDPProblem](https://github.com/JuliaPOMDP/TagPOMDPProblem.jl) | [![CI](https://github.com/JuliaPOMDP/TagPOMDPProblem.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/TagPOMDPProblem.jl/actions/workflows/CI.yml) | [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/TagPOMDPProblem.jl/branch/main/graph/badge.svg?token=UNYWMYUBDL)](https://codecov.io/gh/JuliaPOMDP/TagPOMDPProblem.jl) |
| [DroneSurveillance](https://github.com/JuliaPOMDP/DroneSurveillance.jl) | [![Build status](https://github.com/JuliaPOMDP/DroneSurveillance.jl/workflows/CI/badge.svg)](https://github.com/JuliaPOMDP/DroneSurveillance.jl/actions) | [![codecov](https://codecov.io/gh/juliapomdp/DroneSurveillance.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/juliapomdp/DroneSurveillance.jl) |
| [ContinuumWorld](https://github.com/JuliaPOMDP/ContinuumWorld.jl) | [![CI](https://github.com/JuliaPOMDP/ContinuumWorld.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/ContinuumWorld.jl/actions/workflows/CI.yml) | [![Coverage Status](https://coveralls.io/repos/JuliaPOMDP/ContinuumWorld.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaPOMDP/ContinuumWorld.jl?branch=master) |
| [VDPTag2](https://github.com/zsunberg/VDPTag2.jl) | [![Build Status](https://travis-ci.org/zsunberg/VDPTag2.jl.svg?branch=master)](https://travis-ci.org/zsunberg/VDPTag2.jl) | |
| [RoombaPOMDPs](https://github.com/sisl/RoombaPOMDPs.jl) (Roomba Localization) | [![CI](https://github.com/sisl/RoombaPOMDPs.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/sisl/RoombaPOMDPs.jl/actions/workflows/ci.yml)


#### MDP solvers:

|  **`Package`**   |  **`Build/Coverage`** | Online/<br>Offline | Continuous<br>States - Actions |  Rating<sup>3</sup> |
|-------------------|----------------------|----------------------|-------------------------|--|
| [DiscreteValueIteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl) | [![Build Status](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/DiscreteValueIteration.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/DiscreteValueIteration.jl?branch=master) | Offline | N-N | ★★★★★ |
| [LocalApproximationValueIteration](https://github.com/JuliaPOMDP/LocalApproximationValueIteration.jl) | [![Build Status](https://github.com/JuliaPOMDP/LocalApproximationValueIteration.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/LocalApproximationValueIteration.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/LocalApproximationValueIteration.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/LocalApproximationValueIteration.jl?branch=master) | Offline | Y-N | ★★ |
| [GlobalApproximationValueIteration](https://github.com/JuliaPOMDP/GlobalApproximationValueIteration.jl) | [![Build Status](https://github.com/JuliaPOMDP/GlobalApproximationValueIteration.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/GlobalApproximationValueIteration.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/GlobalApproximationValueIteration.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/GlobalApproximationValueIteration.jl?branch=master) | Offline | Y-N | ★★ |
| [MCTS](https://github.com/JuliaPOMDP/MCTS.jl) (Monte Carlo Tree Search) | [![Build Status](https://github.com/JuliaPOMDP/MCTS.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/MCTS.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/MCTS.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/MCTS.jl?branch=master) | Online | Y (DPW)-Y (DPW) | ★★★★ |

#### POMDP solvers:

|  **`Package`**   |  **`Build/Coverage`** | Online/<br>Offline | Continuous<br>States-Actions-Observations |  Rating<sup>3</sup> |
|-------------------|----------------------|--------------------|---------------------------|--|
| [QMDP](https://github.com/JuliaPOMDP/QMDP.jl) (suboptimal) | [![Build Status](https://github.com/JuliaPOMDP/QMDP.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/QMDP.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/QMDP.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/QMDP.jl)  | Offline | N-N-N | ★★★★★ |
| [FIB](https://github.com/JuliaPOMDP/FIB.jl) (suboptimal) | [![Build Status](https://github.com/JuliaPOMDP/FIB.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/FIB.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/FIB.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/FIB.jl)  | Offline | N-N-N | ★★ |
| [BeliefGridValueIteration](https://github.com/JuliaPOMDP/BeliefGridValueIteration.jl) | [![Build Status](https://github.com/JuliaPOMDP/BeliefGridValueIteration.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/BeliefGridValueIteration.jl) <br> [![codecov](https://codecov.io/gh/JuliaPOMDP/BeliefGridValueIteration.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/BeliefGridValueIteration.jl) | Offline | N-N-N | ★★ |
| [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl)* | [![Build Status](https://github.com/JuliaPOMDP/SARSOP.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/SARSOP.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/SARSOP.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/SARSOP.jl?branch=master) | Offline | N-N-N | ★★★★ |
| [NativeSARSOP](https://github.com/JuliaPOMDP/NativeSARSOP.jl) | [![Build Status](https://github.com/JuliaPOMDP/NativeSARSOP.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/NativeSARSOP.jl/actions/workflows/CI.yml) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/NativeSARSOP.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/NativeSARSOP.jl) | Offline | N-N-N | ★★★★ |
| [ParticleFilterTrees](https://github.com/WhiffleFish/ParticleFilterTrees.jl) (SparsePFT, PFT-DPW) | [![Build Status](https://github.com/WhiffleFish/ParticleFilterTrees.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/WhiffleFish/ParticleFilterTrees.jl/actions/workflows/CI.yml) <br> [![codecov](https://codecov.io/gh/WhiffleFish/ParticleFilterTrees.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/WhiffleFish/ParticleFilterTrees.jl) | Online | Y-Y<sup>2</sup>-Y | ★★★ |
| [BasicPOMCP](https://github.com/JuliaPOMDP/BasicPOMCP.jl) | [![Build Status](https://github.com/JuliaPOMDP/BasicPOMCP.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/BasicPOMCP.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/BasicPOMCP.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/BasicPOMCP.jl?branch=master) | Online | Y-N-N<sup>1</sup> | ★★★★ |
| [ARDESPOT](https://github.com/JuliaPOMDP/ARDESPOT.jl) | [![Build Status](https://github.com/JuliaPOMDP/ARDESPOT.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/ARDESPOT.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/ARDESPOT.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/ARDESPOT.jl?branch=master) | Online | Y-N-N<sup>1</sup> | ★★★★ |
| [AdaOPS](https://github.com/JuliaPOMDP/AdaOPS.jl) | [![CI](https://github.com/JuliaPOMDP/AdaOPS.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/AdaOPS.jl/actions/workflows/CI.yml) <br> [![codecov.io](http://codecov.io/github/JuliaPOMDP/AdaOPS.jl/coverage.svg?branch=main)](http://codecov.io/github/JuliaPOMDP/AdaOPS.jl?branch=main) | Online | Y-N-Y | ★★★★ |
| [MCVI](https://github.com/JuliaPOMDP/MCVI.jl) | [![Build Status](https://github.com/JuliaPOMDP/MCVI.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/MCVI.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/MCVI.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/MCVI.jl?branch=master) | Offline | Y-N-Y | ★★ |
| [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl)* | [![Build Status](https://github.com/JuliaPOMDP/POMDPSolve.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/POMDPSolve.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/POMDPSolve.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/POMDPSolve.jl) | Offline | N-N-N | ★★★ |
| [IncrementalPruning](https://github.com/JuliaPOMDP/IncrementalPruning.jl) | [![Build Status](https://github.com/JuliaPOMDP/IncrementalPruning.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/IncrementalPruning.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/IncrementalPruning.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/IncrementalPruning.jl?branch=master)  | Offline | N-N-N | ★★★ |
| [POMCPOW](https://github.com/JuliaPOMDP/POMCPOW.jl) | [![Build Status](https://github.com/JuliaPOMDP/POMCPOW.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/POMCPOW.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/POMCPOW.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/POMCPOW.jl?branch=master) | Online | Y-Y<sup>2</sup>-Y | ★★★ |
| [AEMS](https://github.com/JuliaPOMDP/AEMS.jl) | [![Build Status](https://github.com/JuliaPOMDP/AEMS.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/AEMS.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/AEMS.jl/badge.svg)](https://coveralls.io/r/JuliaPOMDP/AEMS.jl) | Online | N-N-N | ★★ |
| [PointBasedValueIteration](https://github.com/JuliaPOMDP/PointBasedValueIteration.jl) | [![Build status](https://github.com/JuliaPOMDP/PointBasedValueIteration.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/PointBasedValueIteration.jl/actions/workflows/CI.yml) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/PointBasedValueIteration.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/PointBasedValueIteration.jl?branch=master) | Offline | N-N-N | ★★ |

<sup>1</sup>: Will run, but will not converge to optimal solution

<sup>2</sup>: Will run, but convergence to optimal solution is not proven, and it will likely not work well on multidimensional action spaces. See also https://github.com/michaelhlim/VOOTreeSearch.jl.


#### Reinforcement Learning:

|  **`Package`**   |  **`Build/Coverage`**  | Continuous<br>States | Continuous<br>Actions | Rating<sup>3</sup> |
|-------------------|----------------------|------------------|------------------|--|
| [TabularTDLearning](https://github.com/JuliaPOMDP/TabularTDLearning.jl) | [![Build Status](https://github.com/JuliaPOMDP/TabularTDLearning.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/TabularTDLearning.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/TabularTDLearning.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/TabularTDLearning.jl?branch=master) | N | N | ★★ |
| [DeepQLearning](https://github.com/JuliaPOMDP/DeepQLearning.jl) | [![Build Status](https://github.com/JuliaPOMDP/DeepQLearning.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/DeepQLearning.jl) <br> [![Coverage Status](https://codecov.io/gh/JuliaPOMDP/DeepQLearning.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaPOMDP/DeepQLearning.jl?branch=master) | Y<sup>1</sup> | N | ★★★ |

<sup>1</sup>: For POMDPs, it will use the observation instead of the state as input to the policy.

<sup>3</sup> Subjective rating; File an issue if you believe one should be changed
- ★★★★★: Reliably Computes solution for every problem.
- ★★★★: Works well for most problems. May require some configuration, or not support every edge of interface.
- ★★★: May work well, but could require difficult or significant configuration.
- ★★: Not recently used (unknown condition). May not conform to interface exactly, or may have package compatibility issues
- ★: Not known to run


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
