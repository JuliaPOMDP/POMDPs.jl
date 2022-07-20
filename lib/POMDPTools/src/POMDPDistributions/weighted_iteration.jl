"""
    weighted_iterator(d)

Return an iterator through pairs of the values and probabilities in distribution `d`.

This is designed to speed up value iteration. Distributions are encouraged to provide a custom optimized implementation if possible.

# Example
```julia-repl
julia> d = BoolDistribution(0.7)
BoolDistribution(0.7)

julia> collect(weighted_iterator(d))
2-element Array{Pair{Bool,Float64},1}:
  true => 0.7
 false => 0.3
```
"""
weighted_iterator(d) = (x=>pdf(d, x) for x in support(d))
