# [Defining POMDPs and MDPs](@id defining_pomdps)

As described in the [Concepts and Architecture](@ref) section, an MDP is defined by the state space, action space, transition distributions, reward function, and discount factor, ``(S,A,T,R,\gamma)``. A POMDP also includes the observation space, and observation probability distributions, for a definition of ``(S,A,T,R,O,Z,\gamma)``. A problem definition in POMDPs.jl consists of an implicit or explicit definition of each of these elements. For this discussion, we will use the `QuickPOMDPs.jl` package, since it is the easiest way to define a simple (PO)MDP, though there are also several [Other ways to define a (PO)MDP](@ref).

## A Running Example: The Tiger POMDP

As a running example, we will use the classic Tiger POMDP\[1\]. In the tiger POMDP, the agent is tasked with escaping from a room. There are two doors leading out of the room. Behind one of the doors is a tiger, and behind the other is sweet, sweet freedom. If the agent opens the door and finds the tiger, it gets eaten (and receives a reward of -100). If the agent opens the other door, it escapes and receives a reward of 10. The agent can also listen. Listening gives a noisy measurement of which door the tiger is hiding behind. Listening gives the agent the correct location of the tiger 85% of the time. The agent receives a reward of -1 for listening.

```
using QuickPOMDPs: QuickPOMDP
using POMDPModelTools: Deterministic, Uniform, SparseCat

m = QuickPOMDP(
    states = ["left", "right"],
    actions = ["left", "right", "listen"],
    observations = ["left", "right"],
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
    end,

    initialstate = Uniform(["left", "right"]),
)
```

## Representing ``S``, ``A``, and ``O``

The state spac

In POMDPs.jl, a state, action, or observation can be represented by any Julia object, for example an integer, a floating point number, a string or `Symbol`, or a vector. The simplest way to state, action, and observation spaces can be represented by any iterable object, e.g. `[1,2,3]`, but, in many cases, the 

!!! warn
    
    Objects representing states, actions, and observations should not be altered once they are created, since they may be used as dictionary keys or stored in histories. Hence it is usually best to use immutable objects.


## Representing ``T`` and ``O``

### Commonly-used distributions

## Representing ``R``

## Representing ``\gamma``

## Optional Components: Initial state distributions and terminal states

## Other ways to define a (PO)MDP

TODO:
- Object-Oriented
- Tabular
- Using a single generative function

\[1\] L. Pack Kaelbling, M. L. Littman, A. R. Cassandra, "Planning and Action in Partially Observable Domain", Artificial Intelligence, 1998.

S and A are defined by implementing
[`states`](@ref) and [`actions`](@ref) for your specific [`MDP`](@ref)
subtype. R is by implementing [`reward`](@ref), and T is defined by implementing [`transition`](@ref) if the [*explicit*](@ref defining_pomdps) interface is used or [`gen`](@ref) if the [*generative*](@ref defining_pomdps) interface is used.
`Z` may be defined by the [`observations`](@ref) function (though an
explicit definition is often not required), and `O` is defined by
implementing [`observation`](@ref) if the [*explicit*](@ref defining_pomdps) interface is used or [`gen`](@ref) if the [*generative*](@ref defining_pomdps) interface is used.


## Consider starting with one of these packages

Since POMDPs.jl was designed with performance and flexibility as first priorities, the interface is larger than needed to express most simple problems. For this reason, several packages and tools have been created to help users implement problems quickly. It is often easiest for new users to start with one of these.

- [QuickPOMDPs.jl](https://github.com/JuliaPOMDP/QuickPOMDPs.jl) provides structures for concisely defining simple POMDPs without object-oriented programming.
- [POMDPExamples.jl](https://github.com/JuliaPOMDP/POMDPExamples.jl) provides tutorials for defining problems. 
- [The Tabular(PO)MDP model](https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-tabular-POMDP.ipynb) from [POMDPModels.jl](https://github.com/JuliaPOMDP/POMDPModels.jl) allows users to define POMDPs with matrices for the transitions, observations and rewards.
- The [`gen`](@ref) function is the easiest way to wrap a pre-existing simulator from another project or written in another programming language so that it can be used with POMDPs.jl solvers and simulators.

## Overview

The expressive nature of POMDPs.jl gives problem writers the flexibility to write their problem in many forms.
Custom POMDP problems are defined by implementing the functions specified by the POMDPs API.

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


