# [Generative (PO)MDP Interface](@id generative_doc)

## Description

The *generative* interface consists of two functions:
- [`gen`](@ref) returns samples (e.g. states, observations and rewards) from a generative POMDP model.
- [`initialstate`](@ref) returns a sampled initial state.
The generative interface is typically used when it is easier to return sampled states and observations rather than explicit distributions as in the [Explicit interface](@ref explicit_doc).
This type of model is often referred to as a "black-box" model.

## Basic Implementation Instructions

To implement the generative interface for a 'POMDP' or 'MDP' type 'M', one should implement

- [`gen`](@ref)`(m::M, s, a, `[`rng`](@ref Random-number-generators)`)`. This should return a [`NamedTuple`](todo link) with entries `sp` (mnemonic "s-prime") for the next state, `r` for the reward, and `o` for the observation (if `M <: POMDP`).
- [`initialstate`](@ref)`(m::M, `[`rng`](@ref Random-number-generators)`)`, which should return a sampled initial state.

## Examples

An example of defining a problem with the generative interface can be found at [https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Generative-Interface.ipynb](https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Generative-Interface.ipynb)

## Advanced concepts

The following sections lay out the details of the generative implementation in POMDPs.jl.

### Specified return types

While [`gen`](@ref)`(m, s, a, rng)` provides a convenient way to specify the next state and reward (and observation for POMDPs), sometimes a solver or updater will only need access to a subset of these outputs. For this case, there are methods of `gen` with return types specified using [`Return`](@ref) objects. For example,
```
gen(Return(:sp, :o), m, s, a, rng)
```
will return a tuple containing only the next state and observation (and not the reward).
[`Return`](@ref) types are value types similar to `Val`.
See the Julia documentation {TODO: link} on value types for more information.

In order to avoid calculating 

Methods of [`gen`](@ref) with [`Return`](@ref) arguments generally do not need to be implemented directly in a problem definition.
Instead they are synthesized automatically by POMDPs.jl if the compiler can find a way to generate all of the returned values using [`gen`](@ref) or a combination of [`gen`](@ref) and other functions.

In some cases it will make sense to directly implement methods of [`gen`](@ref) with the first [`Return`](@ref) argument or use functions from the explicit interface.
See the [Mixing with the explicit interface](@ref) and [Performance considerations](@ref) sections below for more discussion on when this may be appropriate.

### Genvars

The symbols that can be used with [`Return`](@ref) to specify what [`gen`](@ref) returns are known as "genvars".
A human-readable list of all the genvars that POMDPs.jl knows about can be shown with [`list_genvars()`](@ref).
For programmatic use, [`genvars()`](@ref)
Details for the meaning of a genvar can be 
As of this version `POMDPs.genvars` 

### Random number generators

The `rng` argument to functions in the generative interface is a random number generator such as `Base.GLOBAL_RNG` or another `MersenneTwister`. It should be used to generate all random numbers within the function (e.g. use `rand(rng)` instead of `rand()`). This will ensure that all simulations are exactly repeatable. See the [Julia documentation on random numbers](https://docs.julialang.org/en/v1/stdlib/Random/#Random-Numbers-1) for more information about these objects.

### Mixing with the explicit interface

POMDPs.jl will automatically use functions from the [Explicit interface](@ref explicit_doc) if any variables cannot be generated with [`gen`](@ref), so it is reasonable to use parts of both generative and explicit interfaces to define the same problem.
For example, it would be reasonable to implement
```julia
struct M <: POMDP{Int, Int, Float64} end

POMDPs.gen(::M, s, a, rng) = (sp=s+a, r=abs(s))
POMDPs.observation(::M, a, sp) = Normal(sp)
```
and `gen(Return(:sp, :o), M(), 1, 1, Random.GLOBAL_RNG)` will correctly return a new state and observation.

### Performance considerations

In general, calling `gen(::Return, ...)` when `gen(::POMDP, ...)` is implemented does not introduce much overhead. In fact, in some cases, the compiler will even optimize out calculations of extra genvars. For example:
```julia
struct M <: MDP{Int, Int} end

POMDPs.gen(::M, s, a, rng) = (sp=s+a, r=s^2)

@code_warntype gen(Return(:sp), M(), 1, 1, Random.GLOBAL_RNG)
```
will yield
```
Body::Int64
1 ─ %1 = (Base.add_int)(s, a)::Int64
│        nothing
└──      return %1
```
indicating that the compiler will only perform the addition to find the next state and skip the `s^2` calculation for the reward.

Unfortunately, if random numbers are used, the compiler will not be able to optimize out the change in the rng's state, so in this case, it may be beneficial to directly implement versions of `gen` with specified return values.
For example
```julia
POMDPs.gen(::Return{:sp}, ::M, s, a, rng) = s+a
POMDPs.reward(::M, s, a) = abs(s)
PODMPs.gen(::Return{:o}, ::M, s, a, sp, rng) = sp+randn(rng)
```
might be more efficient than
```julia
function POMDPs.gen(::M, s, a, rng)
    sp = s + a
    return (sp=sp, r=abs(s), o=sp+randn(rng))
end
```
in the context of particle filtering.

As always, though, one should resist the urge towards premature optimization; careful profiling to see what is actually slow is much more effective than speculation.
