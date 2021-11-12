# [Defining POMDPs and MDPs](@id defining_pomdps)

As described in the [Concepts and Architecture](@ref) section, an MDP is defined by the state space, action space, transition distributions, reward function, and discount factor, ``(S,A,T,R,\gamma)``. A POMDP also includes the observation space, and observation probability distributions, for a definition of ``(S,A,T,R,O,Z,\gamma)``. A problem definition in POMDPs.jl consists of an implicit or explicit definition of each of these elements.

It is possible to define a (PO)MDP with a more traditional [object-oriented approach](@ref TODO) in which the user defines a new type to represent the (PO)MDP and methods of [interface functions](@ref api) to define the tuple elements. However, the [QuickPOMDPs package](https://github.com/JuliaPOMDP/QuickPOMDPs.jl) provides a more concise way to get started, using keyword arguments instead of new types and methods. Since the important concepts are the same for the object oriented approach and the QuickPOMDP approach, we will use the latter for this discussion.

This guide has two parts: First, it explains a very simple example (the Tiger POMDP), then uses a more complex example to illustrate the broader capabilities of the interface.

!!! note
    This guide assumes that you are comfortable programming in Julia, especially familiar with various ways of defining [*anonymous functions*](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions). Users should consult the [Julia documentation](https://docs.julialang.org) to learn more about programming in Julia.

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

```jldoctest lightdark; output=false, filter=r"QuickPOMDP.*"
import QuickPOMDPs: QuickPOMDP
import POMDPModelTools: ImplicitDistribution
import Distributions: Normal

m = QuickPOMDP(
    actions = [-1., 0., 1.],
    obstype = Float64,
    discount = 0.95,

    transition = function (s, a)        
        ImplicitDistribution() do rng
            x, v = s
            vp = v + a*0.001 + cos(3*x)*-0.0025 + 0.0002*randn(rng)
            vp = clamp(vp, -0.07, 0.07)
            xp = x + vp
            return (xp, vp)
        end
    end,

    observation = (a, sp) -> Normal(sp[1], 0.15),

    reward = function (s, a, sp)
        if sp[1] > 0.5
            return 100.0
        else
            return -1.0
        end
    end,

    initialstate = ImplicitDistribution(rng -> (-0.2*rand(rng), 0.0)),
    isterminal = s -> s[1] > 0.5
)

# output
QuickPOMDP
```

### [State, action, and observation spaces](@id space_representation)

In POMDPs.jl, a state, action, or observation can be represented by any Julia object, for example an integer, a floating point number, a string or `Symbol`, or a vector. For example, in the tiger problem, the states are `String`s, and in the light dark problem, the states and actions are integers, and the observations are floating point numbers.

!!! warn
    
    Objects representing individual states, actions, and observations should not be altered once they are created, since they may be used as dictionary keys or stored in histories. Hence it is usually best to use immutable objects such as integers or [`StaticArray`s](https://github.com/JuliaArrays/StaticArrays.jl).

The state, action, and observation spaces are defined with the `states`, `actions`, and `observations` Quick(PO)MDP keyword arguments. The simplest way to define these spaces is with a `Vector` of states, e.g. `states = ["left", "right"]` in the tiger problem. More complicated spaces, such as vector spaces and other continuous, uncountable, or hybrid sets can be defined with custom objects that adhere to the [space interface](@ref space-interface). However it should be noted that, for many solvers, *an explicit enumeration of the state and observation spaces is not needed*. Instead, it is sufficient to specify the state or observation *type* using the `statetype` or `obstype` arguments, e.g. `obstype = Float64` in the light dark problem.

!!! tip

    If you are having a difficult time representing the state or observation space, it is likely that you will not be able to use a solver that requires an explicit representation. It is usually best to omit that space from the definition and try solvers to see if they work.

#### [State- or belief-dependent action spaces](@id state-dep-action)

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
