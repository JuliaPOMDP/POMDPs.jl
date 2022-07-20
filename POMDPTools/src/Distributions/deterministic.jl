"""
    Deterministic(value)

Create a deterministic distribution over only one value.

This is intended to be used when a distribution is required, but the outcome is deterministic. It is equivalent to a Kronecker Delta distribution.
"""
struct Deterministic{T}
    val::T
end

rand(rng::AbstractRNG, d::Deterministic) = d.val
rand(d::Deterministic) = d.val
support(d::Deterministic) = (d.val,)
sampletype(::Type{Deterministic{T}}) where T = T
Random.gentype(::Type{Deterministic{T}}) where T = T
pdf(d::Deterministic, x) = convert(Float64, x == d.val)
mode(d::Deterministic) = d.val
mean(d::Deterministic{N}) where N<:Number = d.val / 1 # / 1 is to make this return a similar type to Statistics.mean
mean(d::Deterministic) = d.val # so that division need not be implemented for the value type
