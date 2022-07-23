# Frequently Asked Questions (FAQ)

## What is the difference between `transition`, `gen`, and `@gen`?

(See also: [Using a single generative function instead of separate ``T``, ``Z``, and ``R``](@ref))

### For problem implementers

- [`transition`](@ref) should be implemented to define the state transition distribution, either explicitly, or, if only samples from the distribution are available, with an [`ImplicitDistribution`](@ref implicit_distribution_section).
- [`gen`](@ref) should *only* be implemented if your simulator can only output samples of two or more of the next state, observation, and reward *at the same time*, e.g. if rewards are calculated as a robot moves from the current state to the next state so it is difficult to define the [`reward`](@ref) function separately from the state transitions.
- [`@gen`](@ref) should *never* be implemented or modified by the problem writer; it is only used in simulators and solvers (see below).

### For solver/simulator implementers

- [`@gen`](@ref) should be called whenever a sample of the next state, observation, and or reward is needed. It automatically combines calls to `rand`, [`transition`](@ref), [`observation`](@ref), [`reward`](@ref), and [`gen`](@ref), depending on what is implemented for the problem and the outputs requested by the caller without any overhead.
- [`transition`](@ref) should be called *only* when you need access to the explicit transition probability distribution.
- [`gen`](@ref) should *never* be called directly by a solver or simulator; it is only a tool for implementers (see above).

## How do I save my policies?

We recommend using [JLD2](https://github.com/JuliaIO/JLD2.jl) to save the whole policy object:

```julia
using JLD2
save("my_policy.jld2", "policy", policy)
```
## Why is my solver producing a suboptimal policy?

There could be a number of things that are going wrong. If you have a discrete POMDP or MDP and you're using a solver that requires the explicit transition probabilities, the first thing to try is make sure that your probability masses sum up to unity. 
We've provide some tools in POMDPToolbox that can check this for you.
If you have a POMDP called pomdp, you can run the checks by doing the following:

```julia
using POMDPTools
@assert has_consistent_distributions(pomdp)
```

If this throws an error, you may need to fix your `transition` or `observation` functions. 

## What if I don't use the `rng` argument?

POMDPs.jl uses Julia's built-in [random number generator system](https://docs.julialang.org/en/v1/stdlib/Random/) to provide for reproducible simulations. To tie into this system, the [`gen`](@ref) function, the sampling function for the `ImplicitDistribution`, and the [`rand`](@ref) function for custom distributions all have an `rng` argument that should be used to generate random numbers. However in some cases, for example when wrapping a simulator that is tied to the global random number generator or written in another language, it may be impossible or impractical to use this `rng`.

It is natural to wonder if ignoring this `rng` argument will cause problems. For many use cases, it is OK to ignore this argument - the only consequence will be that simulations will not be exactly reproducible unless the random seed is managed separately. Some algorithms, most notably DESPOT, rely on "determinized scenarios" that are implemented with a special `rng`. Some of the guarantees of these algorithms may not be met if the `rng` argument is ignored.

## Why are all the solvers in separate modules?

We did not put all the solvers and support tools into POMDPs.jl, because we wanted POMDPs.jl to be a lightweight
interface package.
This has a number of advantages. The first is that if a user only wants to use a few solvers from the
JuliaPOMDP organization, they do not have to install all the other solvers and their dependencies.
The second advantage is that people who are not directly part of the JuliaPOMDP organization can write their own solvers
without going into the source code of other solvers. This makes the framework easier to adopt and to extend.

## How can I implement terminal actions?

Terminal actions are actions that cause the MDP to terminate without generating a new state. POMDPs.jl handles terminal conditions via the `isterminal` function on states, and does not directly support terminal actions. If your MDP has a terminal action, you need to implement the model functions accordingly to generate a terminal state. In both generative and explicit cases, you will need some dummy state, say `spt`, that can be recognized as terminal by the `isterminal` function. One way to do this is to give `spt` a state value that is out of bounds (e.g. a vector of `NaN`s or `-1`s) and then check for that in `isterminal`, so that this does not clash with any conventional termination conditions on the state.

If a terminal action is taken, regardless of current state, the `transition` function should return a distribution with only one next state, `spt`, with probability 1.0. In the generative case, the new state generated should be `spt`. The `reward` function or the `r` in `generate_sr` can be set according to the cost of the terminal action.

## Why are there two versions of `reward`?

Both `reward(m, s, a)` and `reward(m, s, a, sp)` are included because of these two facts:

1) Some non-native solvers use `reward(m, s, a)`
2) Sometimes the reward depends on `s` and `sp`.

It is reasonable to implement both as long as the (s, a) version is the expectation of the (s, a, s') version (see below).

## How do I implement `reward(m, s, a)` if the reward depends on the next state?

The solvers that require `reward(m, s, a)` only work on problems with finite state and action spaces. In this case, you can define `reward(m, s, a)` in terms of `reward(m, s, a, sp)` with the following code:

```julia
const rdict = Dict{Tuple{S,A}, Float64}()

for s in states(m)
  for a in actions(m)
    r = 0.0
    td = transition(m, s, a) # transition distribution for s, a
    for sp in support(td)
      r += pdf(td, sp)*reward(m, s, a, sp)
    end
    rdict[(s, a)] = r
  end
end

POMDPs.reward(m, s, a) = rdict[(s, a)]
```

## Why do I need to put type assertions pomdp::POMDP into the function signature?

Specifying the type in your function signature allows Julia to call the appropriate function when your custom type is
passed into it.
For example if a POMDPs.jl solver calls `states` on the POMDP that you passed into it, the correct `states` function
will only get dispatched if you specified that the `states` function you wrote works with your POMDP type. Because Julia
supports multiple-dispatch, these type assertion are a way for doing object-oriented programming in Julia.


