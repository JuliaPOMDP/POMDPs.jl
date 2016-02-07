#################################################################
# This file defines the abstract distribution type
# AbstractDistribution: the abstract super type for the transition and observation distributions
# DiscreteDistribution: discrete distributions support state indexing and length functions
#################################################################

@pomdp_func create_transition_distribution{S,A,O}(pomdp::POMDP{S,A,O})
@pomdp_func create_observation_distribution{S,A,O}(pomdp::POMDP{S,A,O})
@pomdp_func rand{T}(rng::AbstractRNG, d::AbstractDistribution{T}, sample::T)
@pomdp_func pdf{T}(d::AbstractDistribution{T}, x::T)
@pomdp_func domain{T}(d::AbstractDistribution{T})

abstract DiscreteDistribution{T} <: AbstractDistribution{T}

@pomdp_func Base.length{T}(d::DiscreteDistribution{T})
@pomdp_func weight{T}(d::DiscreteDistribution{T}, i::Int)
@pomdp_func index{S,A,O,T}(pomdp::POMDP{S,A,O}, d::DiscreteDistribution{T}, i::Int)
