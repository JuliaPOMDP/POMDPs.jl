"""
    gen(m::Union{MDP,POMDP}, s, a, rng::AbstractRNG)

Function for implementing the entire MDP/POMDP generative model by returning a `NamedTuple`.

Solver and simulator writers should use the `@gen` macro to call a generative model.

# Arguments
- `m`: an `MDP` or `POMDP` model
- `s`: the current state
- `a`: the action
- `rng`: a random number generator (Typically a `MersenneTwister`)

# Return
The function should return a [`NamedTuple`](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple). With a subset of following entries:

## MDP
- `sp`: the next state
- `r`: the reward for the step
- `info`: extra debugging information, typically in an associative container like a NamedTuple

## POMDP
- `sp`: the next state
- `o`: the observation
- `r`: the reward for the step
- `info`: extra debugging information, typically in an associative container like a NamedTuple

Some elements can be left out. For instance if `o` is left out of the return, the problem-writer can also implement `observation` and POMDPs.jl will automatically use it when needed.

# Example
```julia
struct LQRMDP <: MDP{Float64, Float64} end

POMDPs.gen(m::LQRMDP, s, a, rng) = (sp = s + a + randn(rng), r = -s^2 - a^2)
```
"""
function gen end

"""
    @gen(X)(m, s, a)
    @gen(X)(m, s, a, rng::AbstractRNG)

Call the generative model for a (PO)MDP `m`; Sample values from several nodes in the dynamic decision network. X is one or more symbols indicating which nodes to output.

Solvers and simulators should call this rather than the `gen` function. Problem writers should implement a method of the `transition` or `gen` function instead of altering `@gen`.

# Arguments
- `m`: an `MDP` or `POMDP` model
- `s`: the current state
- `a`: the action
- `rng` (optional): a random number generator (Typically a `MersenneTwister`)

# Return
If `X`, is a symbol, return a value sample from the corresponding node. If `X` is several symbols, return a `Tuple` of values sampled from the specified nodes.

# Examples
Let `m` be an `MDP` or `POMDP`, `s` be a state of `m`, `a` be an action of `m`, and `rng` be an `AbstractRNG`.
- `@gen(:sp, :r)(m, s, a)` returns a `Tuple` containing the next state and reward.
- `@gen(:sp, :o, :r)(m, s, a, rng)` returns a `Tuple` containing the next state, observation, and reward.
- `@gen(:sp)(m, s, a, rng)` returns the next state.
"""
macro gen(symbols...)
    quote
        # this should be an anonymous function, but there is a bug (https://github.com/JuliaLang/julia/issues/36272)
        f(m, s, a, rng=Random.GLOBAL_RNG) = genout(DDNOut($(symbols...)), m, s, a, rng)
    end
end
