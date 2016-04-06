#################################################################
# This file defines the abstract distribution type
# AbstractDistribution: the abstract super type for the transition and observation distributions
# DiscreteDistribution: discrete distributions support state indexing and length functions
#################################################################

"""
    create_transition_distribution{S,A,O}(pomdp::POMDP{S,A,O})

Returns a transition distribution (for memory preallocation).
"""
@pomdp_func create_transition_distribution{S,A,O}(pomdp::POMDP{S,A,O})

"""
    create_observation_distribution{S,A,O}(pomdp::POMDP{S,A,O})

Returns an observation distribution (for memory preallocation).
"""
@pomdp_func create_observation_distribution{S,A,O}(pomdp::POMDP{S,A,O})

"""
    rand{T}(rng::AbstractRNG, d::AbstractDistribution{T}, sample::T)

Fill `sample` with a random element from distribution `d`. The sample can be a state, action or observation.
"""
@pomdp_func rand{T}(rng::AbstractRNG, d::AbstractDistribution{T}, sample::T)

"""
    pdf{T}(d::AbstractDistribution{T}, x::T)

Value of probability distribution `d` function at sample `x`.
"""
@pomdp_func pdf{T}(d::AbstractDistribution{T}, x::T)

# TODO (max): does this have a purpose now that we have iterator?
@pomdp_func domain{T}(d::AbstractDistribution{T})

# TODO (max): need an explicit treamtent of discrete distributions?
abstract DiscreteDistribution{T} <: AbstractDistribution{T}
@pomdp_func Base.length{T}(d::DiscreteDistribution{T})
@pomdp_func weight{T}(d::DiscreteDistribution{T}, i::Int)
@pomdp_func index{S,A,O,T}(pomdp::POMDP{S,A,O}, d::DiscreteDistribution{T}, i::Int)
