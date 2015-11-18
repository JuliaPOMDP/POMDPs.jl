#################################################################
# This file defines the abstract distribution and space type
# AbstractDistribution: the abstract super type for the transition and observation distributions
# DiscreteDistribution: discrete distributions support state indexing and length functions
# AbstractSpace: the abstract super type for the state, action and observation spaces
#################################################################

abstract AbstractDistribution

@pomdp_func create_transition_distribution(pomdp::POMDP)
@pomdp_func create_observation_distribution(pomdp::POMDP)
@pomdp_func rand!(rng::AbstractRNG, state::Any, d::AbstractDistribution)
@pomdp_func pdf(d::AbstractDistribution, x::Any)
@pomdp_func domain(d::AbstractDistribution)

abstract DiscreteDistribution <: AbstractDistribution

@pomdp_func Base.length(d::DiscreteDistribution)
@pomdp_func weight(d::DiscreteDistribution, i::Int)
@pomdp_func index(pomdp::POMDP, d::DiscreteDistribution, i::Int)

abstract AbstractSpace 

# returns an integer
@pomdp_func dimensions(s::AbstractSpace)
# returns bound of dim i
@pomdp_func lowerbound(s::AbstractSpace, i::Int)
# returns bound of dim i
@pomdp_func upperbound(s::AbstractSpace, i::Int)
# returns distribution for dim i
@pomdp_func Base.getindex(s::AbstractSpace, i::Int)

@pomdp_func domain(s::AbstractSpace)

# return a space type
@pomdp_func states(pomdp::POMDP)
@pomdp_func states(pomdp::POMDP, state::Any, sts::AbstractSpace=states(pomdp))
@pomdp_func actions(pomdp::POMDP)
@pomdp_func actions(pomdp::POMDP, state::Any, acts::AbstractSpace=actions(pomdp))
@pomdp_func observations(pomdp::POMDP)
@pomdp_func observations(pomdp::POMDP, state::Any, obs::AbstractSpace=observations(pomdp))

