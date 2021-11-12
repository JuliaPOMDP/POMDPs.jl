# [Defining POMDPs and MDPs](@id defining_pomdps)

As described in the [Concepts and Architecture](@ref) section, an MDP is defined by the state space, action space, transition distributions, reward function, and discount factor, ``(S,A,T,R,\gamma)``. A POMDP also includes the observation space, and observation probability distributions, for a definition of ``(S,A,T,R,O,Z,\gamma)``. A problem definition in POMDPs.jl consists of an implicit or explicit definition of each of these elements.

It is possible to define a (PO)MDP with a more traditional [object-oriented approach](@ref TODO) in which the user defines a new type to represent the (PO)MDP and methods of [interface functions](@ref api) to define the tuple elements. However, the [QuickPOMDPs package](https://github.com/JuliaPOMDP/QuickPOMDPs.jl) provides a more concise way to get started, using keyword arguments instead of new types and methods. Since the important concepts are the same for the object oriented approach and the QuickPOMDP approach, we will use the latter for this discussion.

This guide has two parts: First, it explains a very simple example (the Tiger POMDP), then uses a more complex example to illustrate the broader capabilities of the interface.

## [A Basic Example: The Tiger POMDP](@id tiger)

In the first section of this guide, we will explain a QuickPOMDP implementation of a very simple problem: the classic Tiger POMDP\[1\]. In the tiger POMDP, the agent is tasked with escaping from a room. There are two doors leading out of the room. Behind one of the doors is a tiger, and behind the other is sweet, sweet freedom. If the agent opens the door and finds the tiger, it gets eaten (and receives a reward of -100). If the agent opens the other door, it escapes and receives a reward of 10. The agent can also listen. Listening gives a noisy measurement of which door the tiger is hiding behind. Listening gives the agent the correct location of the tiger 85% of the time. The agent receives a reward of -1 for listening. The complete implementation looks like this:

```jldoctest tiger; output=false, filter=r"QuickPOMDP.*"
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

    observation = function (a, sp)
        if a == "listen"
            if sp == "left"
                return SparseCat(["left", "right"], [0.85, 0.15]) # sparse categorical
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
);

# output
QuickPOMDP
```

The next sections explain how each of the elements of the POMDP tuple are defined in this implementation:

#### State, action and observation spaces

In this example, each state, action, and observation is a `String`. The state, action and observation spaces (``S``, ``A``, and ``O``), are defined with the `states`, `actions` and `observations` keyword arguments. In this case, they are simply `Vector`s containing all the elements in the space.

#### Transition and observation distributions

The `transition` and `observation` keyword arguments are used to define the transition distribution, ``T``, and observation distribution, ``Z``, respectively. These models are defined using functions that return [*distribution objects* (more info below)](@ref TODO). The transition function takes state and action arguments and returns a distribution of the resulting next state. The observation function takes in an action and the resulting next state and returns the distribution of the observation emitted at this state.

#### Reward function

The `reward` keyword argument defines ``R``. It is a function that takes in a state and action and returns a number.

#### Discount and initial state distribution

The discount factor, ``\gamma``, is defined with the `discount` keyword, and is simply a number between 0 and 1. The initial state distribution, `b_0`, is defined with the `initialstate` argument, and is a [distribution object](@ref TODO).

The example above shows a complete implementation of a very simple discrete-space POMDP. However, POMDPs.jl is capable of concisely expressing much more complex models with continuous and hybrid spaces. The guide below introduces a more complex example to fully explain the ways that a POMDP can be defined.

## Guide to Defining POMDPs

### [A more complex example: Partially-observable Mountain Car](@id po-mountaincar)

The second example is the slightly more complex [1-D Light Dark problem](https://arxiv.org/pdf/1709.06196v6.pdf). It is more complex because the observation space is continuous and there is a terminal state. A state in this problem is an integer, and the agent can choose how to move deterministically ``(s′ = s+a)`` from the action space ``A = \{−10,−1,0,1,−10\}``.  The goal is to reach the origin. If action 0 is taken at the origin, a reward of 100 is given and the problem terminates; If action 0 is taken at another location, a penalty of −100 is given. There is a cost of −1 at each step before termination. The agent receives a more accurate observation in the “light” region around ``s = 10``. Specifically, observations are continuous ``(O = \mathbb{R})`` and normally distributed with standard deviation ``\sigma = |s −10|``.

```jldoctest lightdark; output=false, filter=r"QuickPOMDP.*"
import QuickPOMDPs: QuickPOMDP
import POMDPModelTools: Deterministic, Uniform
import Distributions: Normal

r = 60
light_loc = 10

simple_lightdark = QuickPOMDP(
    states = -r:r+1,                  # r+1 is a terminal state
    actions = [-10, -1, 0, 1, 10],
    discount = 0.95,
    isterminal = s -> s==r+1,
    obstype = Float64,

    transition = function (s, a)
        if a == 0
            return Deterministic(r+1)
        else
            return Deterministic(clamp(s+a, -r, r))
        end
    end,

    observation = (a, sp) -> Normal(sp, abs(sp - light_loc) + 0.0001),

    reward = function (s, a)
        if a == 0
            return s == 0 ? 100 : -100
        else
            return -1.0
        end
    end,

    initialstate = Uniform(div(-r,2):div(r,2))
);

# output
QuickPOMDP
```

## [Representing ``S``, ``A``, and ``Z``](@id space_representation)

In POMDPs.jl, a state, action, or observation can be represented by any Julia object, for example an integer, a floating point number, a string or `Symbol`, or a vector. For example, in the tiger problem, the states are `String`s, and in the light dark problem, the states and actions are integers, and the observations are floating point numbers.

!!! warn
    
    Objects representing individual states, actions, and observations should not be altered once they are created, since they may be used as dictionary keys or stored in histories. Hence it is usually best to use immutable objects such as integers or [`StaticArray`s](https://github.com/JuliaArrays/StaticArrays.jl).

The state, action, and observation spaces are defined with the `states`, `actions`, and `observations` Quick(PO)MDP keyword arguments. The simplest way to define these spaces is with a `Vector` of states, e.g. `states = ["left", "right"]` in the tiger problem. More complicated spaces, such as vector spaces and other continuous, uncountable, or hybrid sets can be defined with custom objects that adhere to the [space interface](@ref space-interface). However it should be noted that, for many solvers, *an explicit enumeration of the state and observation spaces is not needed*. Instead, it is sufficient to specify the state or observation *type* using the `statetype` or `obstype` arguments, e.g. `obstype = Float64` in the light dark problem.

!!! tip

    If you are having a difficult time representing the state or observation space, it is likely that you will not be able to use a solver that requires an explicit representation. It is usually best to omit that space from the definition and try solvers to see if they work.

### [State- or belief-dependent action spaces](@id state-dep-action)

In some problems, the set of allowable actions depends on the state or belief. This can be implemented by providing a function of the state or belief to the `actions` argument, e.g. if you can only take the action `1` in state `1`, but can take actions `2` and `3`, in an MDP, you might use
```jldoctest ; output=false, filter=r".* \(generic function.*\)"
actions = function (s)
    if s == 1
        return [1,2,3]
    else
        return [2,3]
    end
end

# output
#1 (generic function with 1 method)
```

Similarly, in a POMDP, you may wish to only allow action `1` if the belief `b` assigns a nonzero probability to state `1`. This can be accomplished with
```jldoctest ; output=false
actions = function (b)
    if pdf(b, 1) > 0.0
        return [1,2,3]
    else
        return [2,3]
    end
end

# output
#1 (generic function with 1 method)
```

## Representing ``T`` and ``O``

The transition and observation observation distributions are specified through *functions that return distributions*. A distribution object implements parts of the [distribution interface](@ref Distributions), most importantly a [`rand`](@ref) function that provides a way to sample the distribution and a [`pdf`](@ref) function that evaluates the probability mass or density of a given outcome. In most simple cases, you will be able to use a pre-defined distribution like the ones listed below or the ones in the [Distributions.jl package](https://github.com/JuliaStats/Distributions.jl), but occasionally you will define your own for more complex problems.

The `transition` function takes in a state `s` and action `a` and returns a distribution object that defines the distribution of next states given that the current state is `s` and the action is `a`, that is ``T(s' | s, a)``. Similarly the `observation` function takes in the action `a` and the next state `sp` and returns a distribution object defining ``O(z | a, s')``.



!!! note
    It is also possible to define the `observation` function in terms of the previous state `s`, along with `a`, and `sp`. This is necessary, for example, when the observation is a measurement of change in state, e.g. `sp - s`. However some solvers may use the `a, sp` method (and hence cannot solve problems where the observation is conditioned on ``s`` and ``s'``). Since providing an `a, sp` method *automatically* defines the `s, a, sp` method, problem writers should usually define only the `a, sp` method, and only define the `s, a, sp` method if it is necessary. Except for special performance cases, problem writers should *never* need to define both methods.

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


