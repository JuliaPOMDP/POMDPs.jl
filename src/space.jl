#################################################################
# This file defines an abstract type to represent spaces and abstract functions to specify the spaces
# AbstractSpace: the abstract super type for the state, action and observation spaces
#################################################################

abstract AbstractSpace{T}

# returns an integer
@pomdp_func dimensions{T}(s::AbstractSpace{T})
# returns bound of dim i
@pomdp_func lowerbound{T}(s::AbstractSpace{T}, i::Int)
# returns bound of dim i
@pomdp_func upperbound{T}(s::AbstractSpace{T}, i::Int)
# sample a space and return the sample
@pomdp_func rand{T}(rng::AbstractRNG, d::AbstractSpace{T}, state::T)
# return an iterable object corresponding to the space
@pomdp_func iterator{T}(s::AbstractSpace{T})

# return a space type
@pomdp_func states{S,A,O}(pomdp::POMDP{S,A,O})
@pomdp_func states{S,A,O}(pomdp::POMDP{S,A,O}, state::S, sts::AbstractSpace{S}=states(pomdp))
@pomdp_func actions{S,A,O}(pomdp::POMDP{S,A,O})
@pomdp_func actions{S,A,O}(pomdp::POMDP{S,A,O}, state::S, acts::AbstractSpace{A}=actions(pomdp))
@pomdp_func actions{S,A,O}(pomdp::POMDP{S,A,O}, belief::Belief{S}, acts::AbstractSpace{A}=actions(pomdp))
@pomdp_func observations{S,A,O}(pomdp::POMDP{S,A,O})
@pomdp_func observations{S,A,O}(pomdp::POMDP{S,A,O}, state::S, obs::AbstractSpace{O}=observations(pomdp))
