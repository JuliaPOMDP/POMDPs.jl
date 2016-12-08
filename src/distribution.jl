#################################################################
# This file defines the abstract distribution type
# AbstractDistribution: the abstract super type for the transition and observation distributions
# DiscreteDistribution: discrete distributions support state indexing and length functions
#################################################################

"""
    rand{T}(rng::AbstractRNG, d::AbstractDistribution{T})

Return a random element from distribution `d`. The sample can be a state, action or observation.
"""
Base.rand

"""
    pdf{T}(d::AbstractDistribution{T}, x::T)

Value of probability distribution `d` function at sample `x`.
"""
function pdf end # maybe eventually this should be Distributions.pdf

"""
    iterator{T}(d::AbstractDistribution{T})

Return an iterable type (array or custom iterator) that iterates over possible values of `d`. Values with zero belief may be skipped.
"""
function iterator end
