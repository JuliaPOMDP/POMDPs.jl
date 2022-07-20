"""
    Deterministic(value)

Create a deterministic distribution over only one value.

This is intended to be used when a distribution is required, but the outcome is deterministic. It is equivalent to a Kronecker Delta distribution.
"""
struct Deterministic{T}
    val::T
end

Random.rand(rng::AbstractRNG, d::Deterministic) = d.val
Random.rand(d::Deterministic) = d.val
Distributions.support(d::Deterministic) = (d.val,)
sampletype(::Type{Deterministic{T}}) where T = T
Random.gentype(::Type{Deterministic{T}}) where T = T
Distributions.pdf(d::Deterministic, x) = convert(Float64, x == d.val)
Distributions.mode(d::Deterministic) = d.val
Distributions.mean(d::Deterministic{N}) where N<:Number = d.val / 1 # / 1 is to make this return a similar type to Statistics.mean
Distributions.mean(d::Deterministic) = d.val # so that division need not be implemented for the value type
