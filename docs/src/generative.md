# [Generative (PO)MDP Interface](@id generative_doc)

## Description

The *generative* interface consists of two functions:
- [`gen`](@ref) returns samples (e.g. states, observations and rewards) from a generative POMDP model.
- [`initialstate`](@ref) returns a sampled initial state.
The generative interface is typically used when it is easier to return sampled states and observations rather than explicit distributions as in the [Explicit interface](@ref explicit_doc).

## Basic Implementation Instructions

To implement the generative interface for a 'POMDP' or 'MDP' type 'M', one should implement

- [`gen`](@ref)`(m::M, s, a, `[`rng`](@ref Random-number-generators)`)`. This should return a [`NamedTuple`](todo link) with entries `sp` (mnemonic "s-prime") for the next state, `r` for the reward, and `o` for the observation (if `M <: POMDP`).
- [`initialstate`](@ref)`(m::M, `[`rng`](@ref Random-number-generators)`)`, which should return a sampled initial state.

## Examples

An example of defining a problem with the generative interface can be found at [https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Generative-Interface.ipynb](https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Generative-Interface.ipynb)

## Advanced concepts

The following sections lay out the details of the generative implementation in POMDPs.jl.

### Specified return types

While [`gen`](@ref)`(m, s, a, rng)` provides a convenient way to specify the 

### Genvars



### Random number generators

The `rng` argument to functions in the generative interface is a random number generator such as `Base.GLOBAL_RNG` or another `MersenneTwister`. It should be used to generate all random numbers within the function (e.g. use `rand(rng)` instead of `rand()`). This will ensure that all simulations are exactly repeatable. See the [Julia documentation on random numbers](https://docs.julialang.org/en/v1/stdlib/Random/#Random-Numbers-1) for more information about these objects.

### Mixing with the explicit interface

POMDPs.jl will automatically use function from the [Explicit interface](@ref explicit_doc)

### Performance







contains a small collection of functions that makes implementing and solving problems with generative models easier. These functions return states and observations instead of distributions as in the [Explicit interface](@ref explicit_doc).

The generative interface functions are the following (note that this is not actual julia code):
```julia
generate_s(pomdp, s, a, rng) -> sp
generate_o(pomdp, s, a, sp, rng) -> o
generate_sr(pomdp, s, a, rng) -> (s, r)
generate_so(pomdp, s, a, rng) -> (s, o)
generate_or(pomdp, s, a, sp, rng) -> (o, r)
generate_sor(pomdp, s, a, rng) -> (s, o, r)
initialstate(pomdp, rng) -> s
```

Each `generate_` function is a single step simulator that returns a new state, observation, reward, or a combination given the current state and action (and `sp` in some cases). [`rng` is a random number generator such as `Base.GLOBAL_RNG` or another `MersenneTwister` that is passed as an argument and should be used to generate all random numbers within the function to ensure that all simulations are exactly repeatable.](https://docs.julialang.org/en/v1/stdlib/Random/#Random-Numbers-1)

The functions that do not deal with observations may be defined for `MDP`s as well as `POMDP`s.

A problem writer will generally only have to implement one or two of these functions for all solvers to work (see below).

## Example

An example of defining a problem with the generative interface can be found at [https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Generative-Interface.ipynb](https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Generative-Interface.ipynb)

## Which function(s) should I implement for my problem / use in my solver?

### Problem Writers

Generally, a problem implementer need only implement the simplest one or two of these functions, and the rest are automatically synthesized at runtime.

If there is a convenient way for the problem to generate a combination of states, observations, and rewards simultaneously (for example, if there is a simulator written in another programming language that generates these from the same function, or if it is computationally convenient to generate `sp` and `o` simultaneously), then the problem writer may wish to directly implement one of the combination `generate_` functions, e.g. `generate_sor()` directly.

Use the following logic to determine which functions to implement:
- If you are implementing the problem from scratch in Julia, implement `generate_s` and `generate_o`.
- Otherwise, if your external simulator returns *x*, where *x* is one of *sr*, *so*, *or*, or *sor*, implement `generate_x`. (you may also have to implement `generate_s` separately for use in particle filters).

Note: if an explicit definition is already implemented, you **do not** need to implement any functions from the generative interface - POMDPs.jl will automatically generate implementations of them for you at runtime (see generative_impl.jl).

### Solver and Simulator Writers

Solver writers should use the single function that generates everything that they need and nothing they don't. For example, if the solver needs access to the state, observation, and reward at every timestep, they should use `generate_sor()` rather than `generate_s()` and `generate_or()`, and if the solver needs access to the state and reward, they should use `generate_sr()` rather than `generate_sor()`. This will ensure the widest interoperability between solvers and problems.

In other words, if you need access to *x* where *x* is *s*, *o*, *sr*, *so*, *or*, or *sor* at a certain point in your code, use `generate_x`.

\[1\] *Decision Making Under Uncertainty: Theory and Application* by
Mykel J. Kochenderfer, MIT Press, 2015
