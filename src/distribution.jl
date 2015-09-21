#################################################################
# This file defines the abstract distribution and space type
# AbstractDistribution: the abstract super type for the transition and observation distributions
# DiscreteDistribution: discrete distributions support state indexing and length functions
# AbstractSpace: the abstract super type for the state, action and observation spaces
#################################################################

abstract AbstractDistribution

create_transition_distribution(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_transition_distribution") # creates a dsitribution 
create_observation_distribution(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_observation_distribution") # creates a dsitribution 
rand!(rng::AbstractRNG, state::Any, d::AbstractDistribution) = error("$(typeof(d)) does not implement rand!") # fills with a random state
pdf(d::AbstractDistribution, x::Any) = error("$(typeof(d)) does not implement pdf") # returns a probability

abstract DiscreteDistribution <: AbstractDistribution

Base.length(d::DiscreteDistribution) = error("$(typeof(d)) does not implement length") 
weight(d::DiscreteDistribution, i::Int) = error("$(typeof(d)) does not implement weight")
index(d::DiscreteDistribution, i::Int) = error("$(typeof(d)) does not implement index")

abstract AbstractSpace 

dimensions(s::AbstractSpace) = error("$(typeof(s)) does not implement dimensions") # returns an integer
lowerbound(s::AbstractSpace, i::Int) = error("$(typeof(s)) does not implement lowerbound") # returns bound of dim i
upperbound(s::AbstractSpace, i::Int) = error("$(typeof(s)) does not implement upperbound") # returns bound of dim i 
Base.getindex(s::AbstractSpace, i::Int) = error("$(typeof(s)) does not implement getindex") # returns distribution for dim i

domain(s::AbstractSpace) = error("$(typeof(s)) does not implement domain")

# return a space type
states(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement states") 
states(pomdp::POMDP, state::Any, sts::AbstractSpace=states(pomdp)) = error("$(typeof(pomdp)) does not implement states") 
actions(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement actions") 
actions(pomdp::POMDP, state::Any, acts::AbstractSpace=actions(pomdp)) = error("$(typeof(pomdp)) does not implement actions") 
observations(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement observations") 
observations(pomdp::POMDP, state::Any, obs::AbstractSpace=observations(pomdp)) = error("$(typeof(pomdp)) does not implement observations") 

