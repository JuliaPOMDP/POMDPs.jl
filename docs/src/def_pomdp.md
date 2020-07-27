# [Defining POMDPs and MDPs](@id defining_pomdps)

## Consider starting with one of these packages

Since POMDPs.jl was designed with performance and flexibility as first priorities, the interface is larger than needed to express most simple problems. For this reason, several packages and tools have been created to help users implement problems quickly. It is often easiest for new users to start with one of these.

- [QuickPOMDPs.jl](https://github.com/JuliaPOMDP/QuickPOMDPs.jl) provides structures for concisely defining simple POMDPs without object-oriented programming.
- [POMDPExamples.jl](https://github.com/JuliaPOMDP/POMDPExamples.jl) provides tutorials for defining problems. 
- [The Tabular(PO)MDP model](https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-tabular-POMDP.ipynb) from [POMDPModels.jl](https://github.com/JuliaPOMDP/POMDPModels.jl) allows users to define POMDPs with matrices for the transitions, observations and rewards.
- The [`gen`](@ref) function is the easiest way to wrap a pre-existing simulator from another project or written in another programming language so that it can be used with POMDPs.jl solvers and simulators.

## Overview

The expressive nature of POMDPs.jl gives problem writers the flexibility to write their problem in many forms.
Custom POMDP problems are defined by implementing the functions specified by the POMDPs API.

!!! note

    The main POMDPs.jl interface uses an object-oriented programming paradigm and require familiarity with Julia. For users new to Julia, [QuickPOMDPs](https://github.com/JuliaPOMDP/QuickPOMDPs.jl) usually requires less knowledge of the language and no object-oriented programming.

In this guide, the interface is divided into two sections: functions that define static properties of the problem, and functions that describe the dynamics - how the states, observations and rewards change over time. There are two ways of specifying the dynamic behavior of a POMDP. The problem definition may include a mixture of *explicit* definitions of probability distributions, or *generative* definitions that simulate states and observations without explicitly defining the distributions. In scientific papers explicit definitions are often written as ``T(s' | s, a)`` for transitions and ``O(o | s, a, s')`` for observations, while a generative definition might be expressed as ``s', o, r = G(s, a)`` (or ``s', r = G(s,a)`` for an MDP).

## What do I need to implement?

Because of the wide variety or problems and solvers that POMDPs.jl interfaces with, the question of which functions from the interface need to be implemented does not have a short answer for all cases. In general, a problem will be defined by implementing a combination of functions.

Specifically, a problem writer will need to define
- Explicit or generative definitions for 
    - the state transition model,
    - the reward function, and
    - the observation model.
- Functions to define some other properties of the problem such as the state, action, and observation spaces, which states are terminal, etc.

The precise answer for which functions need to be implemented depends on two factors: problem complexity and which solver will be used.
In particular, 2 questions should be asked:
1. Is it difficult or impossible to specify a probability distribution explicitly?
2. What solvers will be used to solve this, and what are their requirements?

If the answer to (1) is yes, then a generative definition should be used. Question (2) should be answered by reading about the solvers and trying to run them. Some solvers have specified their requirements using the [POMDPLinter package](https://github.com/JuliaPOMDP/POMDPLinter.jl), however, these requirements are written separately from the solver code, and often the best way is to write a simple prototype problem and running the solver until all `MethodError`s have been fixed.

!!! note

    If a particular function is required by a solver but seems very difficult to implement for a particular problem, one should consider carefully whether the algorithm is capable of solving that problem. For example, if a problem has a complex hybrid state space, it will be more difficult to define [`states`](@ref), but it is also true that solvers that require [`states`](@ref) such as SARSOP or IncrementalPruning, will usually not be able to solve such a problem, and solvers that can handle it, like ARDESPOT or MCVI, usually will not call [`states`](@ref).

## Outline

The following pages provide more details on specific parts of the interface:

- [Static Properties](@ref static)
- [Spaces and Distributions](@ref)
- [Dynamics](@ref dynamics)
