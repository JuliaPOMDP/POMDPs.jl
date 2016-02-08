#################################################################
# This file defines the abstract distribution type
# AbstractDistribution: the abstract super type for the transition and observation distributions
# DiscreteDistribution: discrete distributions support state indexing and length functions
#################################################################

@pomdp_func create_transition_distribution(pomdp::POMDP)
@pomdp_func create_observation_distribution(pomdp::POMDP)
@pomdp_func rand(rng::AbstractRNG, d::AbstractDistribution, sample::Any)
@pomdp_func pdf(d::AbstractDistribution, x::Any)
@pomdp_func iterator(d::AbstractDistribution)
@pomdp_func domain(d::AbstractDistribution)

abstract DiscreteDistribution <: AbstractDistribution

@pomdp_func Base.length(d::DiscreteDistribution)
@pomdp_func weight(d::DiscreteDistribution, i::Int)
@pomdp_func index(pomdp::POMDP, d::DiscreteDistribution, i::Int)
