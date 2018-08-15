#############################
# Interface for distributions
#############################

"""
    rand{T}(rng::AbstractRNG, d::Any)

Return a random element from distribution or space `d`.

If `d` is a state or transition distribution, the sample will be a state; if `d` is an action distribution, the sample will be an action or if `d` is an observation distribution, the sample will be an observation.
"""
function rand end

"""
    pdf(d::Any, x::Any)

Evaluate the probability density of distribution `d` at sample `x`.
"""
function pdf end

"""
    mode(d::Any)

Return the most likely value in a distribution d.
"""
function mode end

"""
    mean(d::Any)

Return the mean of a distribution d.
"""
function mean end

"""
    support(d::Any)

Return the possible values that can be sampled from distribution d. Values with zero probability may be skipped.
"""
function support end

"""
    iterator(d::Any)

DEPRECATED. Return an iterable object (array or custom iterator) that iterates over possible values of distribution `d`. Values with zero probability may be skipped.
"""
@generated function iterator(x::Any)
    @warn("POMDPs.iterator(x) is deprecated. Simply iterate over the space directly or use support(d) for distributions.")
    return :(support(x))
end

"""
    sampletype(T::Type)
    sampletype(d::Any) = sampletype(typeof(d))

Return the type of objects that are sampled from a distribution or space `d` when `rand(rng, d)` is called.

The distribution writer should implement the `sampletype(::Type)` method for the distribution type, then the function can be called for that type or for objects of that type (i.e. the `sampletype(d::Any) = sampletype(typeof(d))` default is provided).
"""
function sampletype end

sampletype(d::Any) = sampletype(typeof(d))
sampletype(t::Type) = throw(MethodError(sampletype, (t,)))

implemented(f::typeof(sampletype), TT::Type{Tuple{T}}) where T<:Type = hasmethod(f, TT) && which(f, TT).module != POMDPs
implemented(f::typeof(sampletype), ::Type{Tuple{T}}) where T = implemented(f, Tuple{Type{T}})
