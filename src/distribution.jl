#############################
# Interface for distributions
#############################

"""
    rand{T}(rng::AbstractRNG, d::Any)

Return a random element from distribution or space `d`. The sample can be a state, action or observation.
"""
Base.rand

"""
    pdf(d::Any, x::Any)

Evaluate the probability density of distribution `d` at sample `x`.
"""
function pdf end # maybe eventually this should be Distributions.pdf

"""
    mode(d::Any)

Return the most likely value in a distribution d.
"""
function mode end

"""
    mean(d::Any)

Return the mean of a distribution d.
"""
Base.mean

"""
    iterator(d::Any)

Return an iterable type (array or custom iterator) that iterates over possible values of distribution or space `d`. Values with zero probability may be skipped.
"""
function iterator end

iterator(a::AbstractArray) = a

"""
    sampletype(T::Type)
    sampletype(d::Any) = sampletype(typeof(d))

Return the type of objects that are sampled from a distribution or space `d` when `rand(rng, d)` is called.

Only the `sampletype(::Type)` method should be implemented for a type, but it can be called on objects.
"""
function sampletype end

sampletype(d::Any) = sampletype(typeof(d))
sampletype(t::Type) = throw(MethodError(sampletype, (t,)))

implemented{T<:Type}(sampletype, TT::Tuple{T}) = method_exists(f, TT)
implemented{T}(sampletype, ::Tuple{T}) = implemented(sampletype, Tuple{Type{T}})
