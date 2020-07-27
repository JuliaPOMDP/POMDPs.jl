# Spaces and Distributions

Two important components of the definitions of MDPs and POMDPs are *spaces*, which specify the possible states, actions, and observations in a problem and *distributions*, which define probability distributions. In order to provide for maximum flexibility spaces and distributions may be of any type (i.e. there are no abstract base types). Solvers and simulators will interact with space and distribution types using the functions defined below.

## [Spaces](@id space-interface)

A space object should contain the information needed to define the set of all possible states, actions or observations. The implementation will depend on the attributes of the elements. For example, if the space is continuous, the space object may only contain the limits of the continuous range. In the case of a discrete problem, a vector containing all states is appropriate for representing a space.

The following functions may be called on a space object (Click on a function to read its documentation):

- [`rand`](@ref)
- [`iterate`](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration-1) and [the rest of the iteration interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration-1) for discrete spaces.

## Distributions

A distribution object represents a probability distribution.

The following functions may be called on a distribution object (Click on a function to read its documentation):

- [`rand`](@ref)`([rng,] d)` [^1]
- [`support`](@ref)
- [`pdf`](@ref)
- [`mode`](@ref)
- [`mean`](@ref)

You can find some useful pre-made distribution objects in [Distributions.jl](https://github.com/JuliaStats/Distributions.jl) or [POMDPModelTools.jl](https://juliapomdp.github.io/POMDPModelTools.jl/latest/distributions.html).

[^1]: Distributions should support both `rand(rng::AbstractRNG, d)` and `rand(d)`. The recommended way to do this is by implmenting `Base.rand(rng::AbstractRNG, s::Random.SamplerTrivial{<:YourDistribution})` from the [julia rand interface](https://docs.julialang.org/en/v1/stdlib/Random/index.html#Generating-values-from-a-collection-1).
