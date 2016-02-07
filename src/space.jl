#################################################################
# This file defines an abstract type to represent spaces and abstract functions to specify the spaces
# AbstractSpace: the abstract super type for the state, action and observation spaces
#################################################################

abstract AbstractSpace 

# returns an integer
@pomdp_func dimensions(s::AbstractSpace)
# returns bound of dim i
@pomdp_func lowerbound(s::AbstractSpace, i::Int)
# returns bound of dim i
@pomdp_func upperbound(s::AbstractSpace, i::Int)
# sample a space and return the sample
@pomdp_func rand(rng::AbstractRNG, d::AbstractSpace, state::Any)
# return an iterable object corresponding to the space
@pomdp_func iterator(s::AbstractSpace)

# return a space type
@pomdp_func states(pomdp::POMDP)
@pomdp_func states(pomdp::POMDP, state::State, sts::AbstractSpace=states(pomdp))
@pomdp_func actions(pomdp::POMDP)
@pomdp_func actions(pomdp::POMDP, state::State, acts::AbstractSpace=actions(pomdp))
@pomdp_func actions(pomdp::POMDP, belief::Belief, acts::AbstractSpace=actions(pomdp))
@pomdp_func observations(pomdp::POMDP)
@pomdp_func observations(pomdp::POMDP, state::State, obs::AbstractSpace=observations(pomdp))
