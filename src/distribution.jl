#################################################################
# This file defines the abstract distribution type
# AbstractDistribution: the abstract super type for the transition and observation distributions
# DiscreteDistribution: discrete distributions support state indexing and length functions
#################################################################

"""
    create_transition_distribution(problem::POMDP)
    create_transition_distribution(problem::MDP)

Returns a transition distribution (for memory preallocation).
"""
@pomdp_func create_transition_distribution(problem::Union{POMDP,MDP})

"""
    create_observation_distribution(problem::POMDP)
    create_observation_distribution(problem::MDP)

Returns an observation distribution (for memory preallocation).
"""
@pomdp_func create_observation_distribution(problem::Union{POMDP,MDP})

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

"""
    iterator{T}(d::AbstractDistribution{T})

Returns an iterable type (array or custom iterator) corresponding to distribution `d`. 
"""
@pomdp_func iterator{T}(d::AbstractDistribution{T})

# TODO (max): does this have a purpose now that we have iterator?
@pomdp_func domain{T}(d::AbstractDistribution{T})

# TODO (max): need an explicit treamtent of discrete distributions?
abstract DiscreteDistribution{T} <: AbstractDistribution{T}
@pomdp_func Base.length{T}(d::DiscreteDistribution{T})
@pomdp_func weight{T}(d::DiscreteDistribution{T}, i::Int)
@pomdp_func index{T}(problem::Union{POMDP,MDP}, d::DiscreteDistribution{T}, i::Int)
