#################################################################
# This file defines the abstract distribution type
# AbstractDistribution: the abstract super type for the transition and observation distributions
# DiscreteDistribution: discrete distributions support state indexing and length functions
#################################################################

"""
    create_transition_distribution(problem::POMDP)
    create_transition_distribution(problem::MDP)

Return a transition distribution (for memory preallocation).
"""
@pomdp_func create_transition_distribution(problem::Union{POMDP,MDP})

"""
    create_observation_distribution(problem::POMDP)
    create_observation_distribution(problem::MDP)

Return an observation distribution (for memory preallocation).
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

Return an iterable type (array or custom iterator) that iterates over possible values of `d`. Values with zero belief may be skipped.
"""
@pomdp_func iterator{T}(d::AbstractDistribution{T})
