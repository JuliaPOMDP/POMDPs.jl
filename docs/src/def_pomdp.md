# [Defining POMDPs and MDPs](@id defining_pomdps)

As described in the [Concepts and Architecture](@ref) section, an MDP is defined by the state space, action space, transition distributions, reward function, and discount factor, ``(S,A,T,R,\gamma)``. A POMDP also includes the observation space, and observation probability distributions, for a definition of ``(S,A,T,R,O,Z,\gamma)``. A problem definition in POMDPs.jl consists of an implicit or explicit definition of each of these elements.

It is possible to define a (PO)MDP with a more traditional [object-oriented approach](@ref Object-oriented) in which the user defines a new type to represent the (PO)MDP and methods of [interface functions](@ref API-Documentation) to define the tuple elements. However, the [QuickPOMDPs package](https://github.com/JuliaPOMDP/QuickPOMDPs.jl) provides a more concise way to get started, using keyword arguments instead of new types and methods. Essentially each keyword argument defines a corresponding [POMDPs api function](@ref API-Documentation). Since the important concepts are the same for the object oriented approach and the QuickPOMDP approach, we will use the latter for this discussion.

This guide has three parts: First, it explains a very simple example (the Tiger POMDP), then uses a more complex example to illustrate the broader capabilities of the interface. Finally, some alternative ways of defining (PO)MDPs are discussed.

!!! note
    This guide assumes that you are comfortable programming in Julia, especially familiar with various ways of defining [*anonymous functions*](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions). Users should consult the [Julia documentation](https://docs.julialang.org) to learn more about programming in Julia.

## [A Basic Example: The Tiger POMDP](@id tiger)

In the first section of this guide, we will explain a QuickPOMDP implementation of a very simple problem: the [classic Tiger POMDP](https://www.sciencedirect.com/science/article/pii/S000437029800023X). In the tiger POMDP, the agent is tasked with escaping from a room. There are two doors leading out of the room. Behind one of the doors is a tiger, and behind the other is sweet, sweet freedom. If the agent opens the door and finds the tiger, it gets eaten (and receives a reward of -100). If the agent opens the other door, it escapes and receives a reward of 10. The agent can also listen. Listening gives a noisy measurement of which door the tiger is hiding behind. Listening gives the agent the correct location of the tiger 85% of the time. The agent receives a reward of -1 for listening. The complete implementation looks like this:

```jldoctest tiger; output=false, filter=r"QuickPOMDP.*"
using QuickPOMDPs: QuickPOMDP
using POMDPTools: Deterministic, Uniform, SparseCat

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

The `transition` and `observation` keyword arguments are used to define the transition distribution, ``T``, and observation distribution, ``Z``, respectively. These models are defined using functions that return [*distribution objects* (more info below)](@ref Commonly-used-distributions). The transition function takes state and action arguments and returns a distribution of the resulting next state. The observation function takes in an action and the resulting next state (`sp`, short for "s prime") and returns the distribution of the observation emitted at this state.

#### Reward function

The `reward` keyword argument defines ``R``. It is a function that takes in a state and action and returns a number.

#### Discount and initial state distribution

The discount factor, ``\gamma``, is defined with the `discount` keyword, and is simply a number between 0 and 1. The initial state distribution, `b_0`, is defined with the `initialstate` argument, and is a [distribution object](@ref Commonly-used-distributions).

The example above shows a complete implementation of a very simple discrete-space POMDP. However, POMDPs.jl is capable of concisely expressing much more complex models with continuous and hybrid spaces. The guide below introduces a more complex example to fully explain the ways that a POMDP can be defined.

## Guide to Defining POMDPs

### [A more complex example: A partially-observable mountain car](@id po-mountaincar)

[Mountain car](https://en.wikipedia.org/wiki/Mountain_car_problem) is a classic problem in reinforcement learning. A car starts in a valley between two hills, and must reach the goal at the top of the hill to the right ([see wikipedia for image](https://en.wikipedia.org/wiki/Mountain_car_problem)). The actions are left and right acceleration and neutral and the state consists of the car's position and velocity. In this partially-observable version, there is a small amount of acceleration noise and observations are normally-distributed noisy measurements of the position. This problem can be implemented as follows:

```jldoctest mountaincar; output=false, filter=r"QuickPOMDP.*"
import QuickPOMDPs: QuickPOMDP
import POMDPTools: ImplicitDistribution
import Distributions: Normal

mountaincar = QuickPOMDP(
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

The following sections provide a detailed guide to defining the components of a POMDP using this example and the [tiger pomdp](@ref tiger) further above.

### [State, action, and observation spaces](@id space_representation)

In POMDPs.jl, a state, action, or observation can be represented by any Julia object, for example an integer, a floating point number, a string or `Symbol`, or a vector. For example, in the tiger problem, the states are `String`s, and in the mountaincar problem, the state is a `Tuple` of two floating point numbers, and the actions and observations are floating point numbers. These types are usually inferred from the space or initial state distribution definitions.

!!! warn
    
    Objects representing individual states, actions, and observations should not be altered once they are created, since they may be used as dictionary keys or stored in histories. Hence it is usually best to use immutable objects such as integers or [`StaticArray`s](https://github.com/JuliaArrays/StaticArrays.jl). If the states need to be mutable (e.g. aggregate types with vectors in them), make sure the states are not actualy mutated and that `hash` and `==` functions are implmemented (see [`AutoHashEquals`](https://github.com/andrewcooke/AutoHashEquals.jl))

The state, action, and observation spaces are defined with the `states`, `actions`, and `observations` Quick(PO)MDP keyword arguments. The simplest way to define these spaces is with a `Vector` of states, e.g. `states = ["left", "right"]` in the tiger problem. More complicated spaces, such as vector spaces and other continuous, uncountable, or hybrid sets can be defined with custom objects that adhere to the [space interface](@ref space-interface). However it should be noted that, for many solvers, *an explicit enumeration of the state and observation spaces is not needed*. Instead, it is sufficient to specify the state or observation *type* using the `statetype` or `obstype` arguments, e.g. `obstype = Float64` in the mountaincar problem.

!!! tip

    If you are having a difficult time representing the state or observation space, it is likely that you will not be able to use a solver that requires an explicit representation. It is usually best to omit that space from the definition and try solvers to see if they work.

#### [State- or belief-dependent action spaces](@id state-dep-action)

In some problems, the set of allowable actions depends on the state or belief. This can be implemented by providing a function of the state or belief to the `actions` argument, e.g. if you can only take the action `1` in state `1`, but can take full action space `1`, `2` and `3`, in an MDP, you might use
```jldoctest ; output=false, filter=r".* \(generic function.*\)"
# add default vlaue "s = nothing" , "actions(mdp)" won't throw error.
actions = function (s = nothing) 
    if s == 1
        return [1]      #<--- return state-dep-actions
    else
        return [1,2,3]  #<--- return full action space here
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

### Transition and observation distributions

The transition and observation observation distributions are specified through *functions that return distributions*. A distribution object implements parts of the [distribution interface](@ref Distributions), most importantly a [`rand`](@ref) function that provides a way to sample the distribution and, for explicit distributions, a [`pdf`](@ref) function that evaluates the probability mass or density of a given outcome. In most simple cases, you will be able to use a pre-defined distribution like the ones listed below, but occasionally you will define your own for more complex problems.

!!! tip
    Since the `transition` and `observation` functions return distributions, you should not call `rand` within these functions (unless it is within an [`ImplicitDistribution`](@ref implicit_distribution_section) sampling function (see below)).

The `transition` function takes in a state `s` and action `a` and returns a distribution object that defines the distribution of next states given that the current state is `s` and the action is `a`, that is ``T(s' | s, a)``. Similarly the `observation` function takes in the action `a` and the next state `sp` and returns a distribution object defining ``O(z | a, s')``.

!!! note
    It is also possible to define the `observation` function in terms of the previous state `s`, along with `a`, and `sp`. This is necessary, for example, when the observation is a measurement of change in state, e.g. `sp - s`. However some solvers may use the `a, sp` method (and hence cannot solve problems where the observation is conditioned on ``s`` and ``s'``). Since providing an `a, sp` method *automatically* defines the `s, a, sp` method, problem writers should usually define only the `a, sp` method, and only define the `s, a, sp` method if it is necessary. Except for special performance cases, problem writers should *never* need to define both methods.

#### Commonly-used distributions

In most cases, the following pre-defined distributions found in the [POMDPTools](@ref pomdptools_section) and [Distributions](https://github.com/JuliaStats/Distributions.jl) packages will be sufficient to define models.

##### `Deterministic`

The `Deterministic` distribution should be used when there is no randomness in the state or observation given the state and action inputs. This commonly occurs when the new state is a deterministic function of the state and action or the state stays the same, for example when the action is `"listen"` in the [tiger example](@ref tiger) above, the transition function returns `Deterministic(s)`.

##### `SparseCat` 

In discrete POMDPs, it is common for the state or observation to have a few possible outcomes with specified probabilities. This can be represented with a sparse categorical `SparseCat` distribution that takes a list of outcomes and a list of associated probabilities as arguments. For instance, in the tiger example above, when the action is `"listen"`, there is an 85% chance of receiving the correct observation. Thus if the state is `"left"`, the observation distribution is `SparseCat(["left", "right"], [0.85, 0.15])`, and `SparseCat(["right", "left"], [0.85, 0.15])` if the state is `"right"`.

Another example where `SparseCat` distributions are useful is in grid-world problems, where there is a high probability of transitioning along the direction of the action, a low probability of transitioning to other adjacent states, and zero probability of transitioning to any other states.

##### `Uniform`

Another common case is a uniform distribution over a space or set of outcomes. This can be represented with a `Uniform` object that takes a set of outcomes as an argument. For example, the initial state distribution in the tiger problem is represented with `Uniform(["left", "right"])` indicating that both states are equally likely.

##### Distributions.jl

If the states or observations have numerical or vector values, the [Distributions.jl package](https://github.com/JuliaStats/Distributions.jl) provides a suite of suitable distributions. For example, the observation function in the [partially-observable mountain car example above](@ref po-mountaincar),
```julia
observation = (a, sp) -> Normal(sp[1], 0.15)
```
returns a `Normal` distribution from this package with a mean that depends on the car's location (the first element of state `sp`) and a standard deviation of 0.15.

##### [`ImplicitDistribution`](@id implicit_distribution_section)

In many cases, especially when the state or observation spaces are continuous or hybrid, it is difficult or impossible to specify the probability density explicitly. Fortunately, many solvers for these problems do not require explicit density information and instead need only samples from the distribution. In this case, an "implicit distribution" or "generative model" is sufficient. In POMDPs.jl, this can be represented using an [`ImplicitDistribution`](@ref) object.

The argument to an `ImplicitDistribution` constructor is a function that takes a random number generator as an argument and returns a sample from the distribution. To see how this works, we'll look at an example inspired by the [mountaincar](@ref po-mountaincar) initial state distribution.
Samples from this distribution are position-velocity tuples where the velocity is always zero, but the position is uniformly distributed between -0.2 and 0. Consider the following code:
```jldoctest
using Random: MersenneTwister
using POMDPTools: ImplicitDistribution

rng = MersenneTwister(1)

d = ImplicitDistribution(rng -> (-0.2*rand(rng), 0.0))
rand(rng, d)
# output
(-0.04720666913240939, 0.0)
```
Here, `rng` is the random number generator. When `rand(rng, d)` is called, the sampling function, `rng -> (-0.2*rand(rng), 0.0)`, is called to generate a state.  The sampling function uses `rng` to generate a random number between 0 and 1 (`rand(rng)`), multiplies it by -0.2 to get the position, and creates a tuple with the position and a velocity of `0.0` and returns an initial state that might be, for instance `(-0.11, 0.0)`. Any time that a solver, belief updater, or simulator needs an initial state for the problem, it will be sampled in this way.

!!! note
    The random number generator is a subtype of `AbstractRNG`. It is important to use this random number generator for all calls to `rand` in the sample function for reproducible results. Moreover some solvers use specialized random number generators that allow them to reduce variance. See also the [What if I don't use the `rng` argument?](@ref) FAQ.

It is also common to use Julia's [`do` block syntax](https://docs.julialang.org/en/v1/manual/functions/#Do-Block-Syntax-for-Function-Arguments) to define more complex sampling functions. For instance the transition function in the mountaincar example returns an [`ImplicitDistribution`](@ref implicit_distribution_section) with a sampling function that (1) generates a new noisy velocity through a `randn` call, then (2) clamps the velocity, and finally (3) integrates the position with Euler's method:
```julia
transition = function (s, a)        
    ImplicitDistribution() do rng
        x, v = s
        vp = v + a*0.001 + cos(3*x)*-0.0025 + 0.0002*randn(rng)
        vp = clamp(vp, -0.07, 0.07)
        xp = x + vp
        return (xp, vp)
    end
end
```
Because of the nonlinear clamp operation, it would be difficult to represent this distribution explicitly.

##### Custom distributions

If none of the distributions above are suitable, for example if you need to represent an explicit distribution with hybrid support, it is not difficult to define your own distributions by implementing the functions in the [distribution interface](@ref Distributions).

### Reward functions

The reward function maps a combination of state, action, and observation arguments to the reward for a step. For instance, the reward function in the mountaincar problem,
```julia
reward = function (s, a, sp)
    if sp[1] > 0.5
        return 100.0
    else
        return -1.0
    end
end
```
takes in the previous state, `s`, the action, `a`, and the resulting state, `sp` and returns a large positive reward if the resulting position, `sp[1]`, is beyond a threshold (note the coupling of the terminal reward) and a small negative reward on all other steps. If the reward in the problem is stochastic, the `reward` function implemented in POMDPs.jl should return the mean reward.

There are two possible reward function argument signatures that a problem-writer might consider implementing for an MDP: `(s, a)` and `(s, a, sp)`. For a POMDP, there is an additional version, `(s, a, sp, o)`. The `(s, a, sp)` version is useful when transition to a terminal state results in a reward, and the `(s, a, sp, o)` version is useful for cases when the reward is associated with an observation, such as a negative reward for the stress caused by a medical diagnostic test that indicates the possibility of a disease. **Problem writers should implement the version with the fewest number of arguments possible**, since the versions with more arguments are automatically provided to solvers and simulators if a version with fewer arguments is implemented.

In rare cases, it may make sense to implement two or more versions of the function, for example if a solver requires `(s, a)`, but the user wants an observation-dependent reward to show up in simulation. It is OK to implement two methods of the reward function as long as the following relationships hold: ``R(s, a) = E_{s'\sim T(s'|s,a)}[R(s, a, s')]`` and ``R(s, a, s') = E_{o \sim Z(o | s, a, s')}[R(s, a, s', o)]``. That is, the versions with fewer arguments *must* be expectations of versions with more arguments.

### Other Components

#### Discount factors

The `discount` keyword argument is simply a number between 0 and 1 used to discount rewards in the future.

#### Initial state distribution

The `initialstate` argument should be a distribution object (see [above](@ref Commonly-used-distributions)) that defines the initial state distribution (and initial belief for POMDPs).

#### Terminal states

The function supplied to the `isterminal` object defines which which states in the POMDP are terminal. The function should take a state as an argument as an argument and return `true` if the state is terminal and `false` otherwise. For example, in the mountaincar example above, `isterminal = s -> s[1] > 0.5` indicates all states where the position, `s[1]` is greater than 0.5 are terminal.

It is assumed that the system will take no further steps once it has reached a terminal state. Since reward is assigned for taking steps, no additional award can be accumulated from a terminal state. Consequently, the most important property of terminal states is that *the value of a terminal state is always zero*. Many solvers leverage this property for efficiency. As in the mountaincar example

## Other ways to define a (PO)MDP

Besides the Quick(PO)MDP approach above, there are several alternative ways to define (PO)MDP models:

### Object-oriented

First, it is possible to create your own (PO)MDP types and implement the components of the POMDP directly as methods of [POMDPs.jl interface functions](@ref API-Documentation). This approach can be thought of as the "low-level" way to define a POMDP, and the QuickPOMDP as merely a syntactic convenience. There are a few things that make this object-oriented approach more cumbersome than the QuickPOMDP approach, but the structure is similar. For example, the [tiger](@ref tiger) QuickPOMDP shown above can be implemented as follows:

```jldoctest; output=false
import POMDPs
using POMDPs: POMDP
using POMDPTools: Deterministic, Uniform, SparseCat

struct TigerPOMDP <: POMDP{String, String, String}
    p_correct::Float64
    indices::Dict{String, Int}

    TigerPOMDP(p_correct=0.85) = new(p_correct, Dict("left"=>1, "right"=>2, "listen"=>3))
end

POMDPs.states(m::TigerPOMDP) = ["left", "right"]
POMDPs.actions(m::TigerPOMDP) = ["left", "right", "listen"]
POMDPs.observations(m::TigerPOMDP) = ["left", "right"]
POMDPs.discount(m::TigerPOMDP) = 0.95
POMDPs.stateindex(m::TigerPOMDP, s) = m.indices[s]
POMDPs.actionindex(m::TigerPOMDP, a) = m.indices[a]
POMDPs.obsindex(m::TigerPOMDP, o) = m.indices[o]

function POMDPs.transition(m::TigerPOMDP, s, a)
    if a == "listen"
        return Deterministic(s) # tiger stays behind the same door
    else # a door is opened
        return Uniform(["left", "right"]) # reset
    end
end

function POMDPs.observation(m::TigerPOMDP, a, sp)
    if a == "listen"
        if sp == "left"
            return SparseCat(["left", "right"], [m.p_correct, 1.0-m.p_correct])
        else
            return SparseCat(["right", "left"], [m.p_correct, 1.0-m.p_correct])
        end
    else
        return Uniform(["left", "right"])
    end
end

function POMDPs.reward(m::TigerPOMDP, s, a)
    if a == "listen"
        return -1.0
    elseif s == a # the tiger was found
        return -100.0
    else # the tiger was escaped
        return 10.0
    end
end

POMDPs.initialstate(m::TigerPOMDP) = Uniform(["left", "right"])
# output
```

It is easy to see that the new methods are similar to the keyword arguments in the QuickPOMDP approach, except that every function has an initial `m` argument that has the newly created POMDP type. There are several differences from the QuickPOMDP approach: First, the POMDP is represented by a new `struct` that is a subtype of `POMDP{S,A,O}`. The state, action, and observation types must be specified as the `S`, `A`, and `O` parameters of the [`POMDP`](@ref) abstract type. Second, this new `struct` may contain problem-specific fields, which makes it easy for others to construct POMDPs that have the same structure but different parameters. For example, in the code above, the `struct` has a `p_correct` parameter that specifies the probability of receiving a correct observation when the "listen" action is taken. The final and most cumbersome difference between this object-oriented approach and using QuickPOMDPs is that the user must implement [`stateindex`](@ref), [`actionindex`](@ref), and [`obsindex`](@ref) to map states, actions, and observations to appropriate indices so that data such as values can be stored and accessed efficiently in vectors.

### Using a single generative function instead of separate ``T``, ``Z``, and ``R``

In some cases, you may wish to use a simulator that generates the next state, observation, and/or reward (``s'``, ``o``, and ``r``) simultaneously. This is sometimes called a "generative model".

For example if you are working on an autonomous driving POMDP, the car may travel for one or more seconds in between POMDP decision steps during which it may accumulate reward and observation measurements. In this case it might be very difficult to create a [`reward`](@ref) or [`observation`](@ref) function based on ``s``, ``a``, and ``s'`` arguments.

For situations like this, `gen` is an alternative to `transition`, `observation`, and `reward`. The `gen` function should take in state, action, and random number generator arguments and return a [`NamedTuple`](https://docs.julialang.org/en/v1/manual/types/#Named-Tuple-Types) with keys `sp` (for "s-prime", the next state), `o`, and `r`. The [mountaincar example above](@ref po-mountaincar) can be implemented with `gen` as shown below.

!!! note
    `gen` is intended *only* for the case where *two or more* of the next state, observation, and reward need to be generated at the same time. If the state transition model can be separated from the reward and observation models, you should implement `transition` with an [`ImplicitDistribution`](@ref implicit_distribution_section) instead of `gen`. See also the "[What is the difference between `transition`, `gen`, and `@gen`?](@ref)" FAQ.

```jldoctest; output=false, filter=r"QuickPOMDP.*"
using QuickPOMDPs: QuickPOMDP
using POMDPTools: ImplicitDistribution

mountaincar = QuickPOMDP(
    actions = [-1., 0., 1.],
    obstype = Float64,
    discount = 0.95,

    gen = function (s, a, rng)
        x, v = s
        vp = v + a*0.001 + cos(3*x)*-0.0025 + 0.0002*randn(rng)
        vp = clamp(vp, -0.07, 0.07)
        xp = x + vp
        if xp > 0.5
            r = 100.0
        else
            r = -1.0
        end
        o = xp + 0.15*randn(rng)
        return (sp=(xp, vp), o=o, r=r)
    end,

    initialstate = ImplicitDistribution(rng -> (-0.2*rand(rng), 0.0)),
    isterminal = s -> s[1] > 0.5
)
# output
QuickPOMDP
```

!!! tip
    `gen` is not tied to the QuickPOMDP approach; it can also be used in the object-oriented paradigm.

!!! tip
    It is possible to mix and match `gen` with `transtion`, `observation`, and `reward`. For example, if the `gen` function returns a `NamedTuple` with `sp` and `r` keys, POMDPs.jl will try to use `gen` to generate states and rewards and the `observation` function to generate observations.

!!! note
    Implementing `gen` instead of `transition`, `observation`, and `reward` will limit which solvers you can use; for example, it is impossible to use a solver that requires an explicit transition distribution

### Tabular

Finally, it is sometimes convenient to define (PO)MDPs with tables that define the transition and observation probabilities and rewards. In this case, the states, actions, and observations must simply be integers.

The code below is a tabular implementation of the [tiger example](@ref tiger) with the states, actions, and observations mapped to the following integers:

|integer | state, action, or observation
|--------|--------
|1       | "left"
|2       | "right"
|3       | "listen"

```jldoctest tabular; output=false, filter=r"TabularPOMDP.*"
using POMDPModels: TabularPOMDP

T = zeros(2,3,2)
T[:,:,1] = [1. 0.5 0.5; 
            0. 0.5 0.5]
T[:,:,2] = [0. 0.5 0.5; 
            1. 0.5 0.5]

O = zeros(2,3,2)
O[:,:,1] = [0.85 0.5 0.5; 
            0.15 0.5 0.5]
O[:,:,2] = [0.15 0.5 0.5; 
            0.85 0.5 0.5]

R = [-1. -100. 10.; 
     -1. 10. -100.]

m = TabularPOMDP(T, R, O, 0.95)
# output
TabularPOMDP([1.0 0.5 0.5; 0.0 0.5 0.5;;; 0.0 0.5 0.5; 1.0 0.5 0.5], [-1.0 -100.0 10.0; -1.0 10.0 -100.0], [0.85 0.5 0.5; 0.15 0.5 0.5;;; 0.15 0.5 0.5; 0.85 0.5 0.5], 0.95)
```
Here `T` is a ``|S| \times |A| \times |S|`` array representing the transition probabilities, with `T[sp, a, s]` `` = T(s' | s, a)``. Similarly, `O` is an ``|O| \times |A| \times |S|`` encoding the observation distribution with `O[o, a, sp]` `` = Z(o | a, s')``, and `R` is a ``|S| \times |A|`` matrix that encodes the reward function. 0.95 is the discount factor.
