#################################################################
# This file defines an abstract type to represent spaces and abstract functions to specify the spaces
# AbstractSpace: the abstract super type for the state, action and observation spaces
#################################################################

"""
Base type for state, action and observation spaces.
    
    T: type that parametarizes the space (state, action, or observation)
"""
abstract AbstractSpace{T}

"""
    dimensions{T}(s::AbstractSpace{T})

Returns the number of dimensions in space `s`.
"""
@pomdp_func dimensions{T}(s::AbstractSpace{T})

"""
    rand{T}(rng::AbstractRNG, d::AbstractSpace{T}, sample::T)

Returns a random `sample` from space `s`.
"""
@pomdp_func rand{T}(rng::AbstractRNG, d::AbstractSpace{T}, sample::T)

"""
    iterator{T}(s::AbstractSpace{T})

Returns an iterable type (array or custom iterator) corresponding to space `s`. 
"""
@pomdp_func iterator{T}(s::AbstractSpace{T})

@pomdp_func lowerbound{T}(s::AbstractSpace{T}, i::Int)
@pomdp_func upperbound{T}(s::AbstractSpace{T}, i::Int)

"""
    states{S,A,O}(pomdp::POMDP{S,A,O})
    
Returns the complete state space of a POMDP. 
"""
@pomdp_func states{S,A,O}(pomdp::POMDP{S,A,O})

"""
    states{S,A,O}(pomdp::POMDP{S,A,O}, state::S)
    
Returns a subset of the state space reachable from `state`. 
"""
@pomdp_func states{S,A,O}(pomdp::POMDP{S,A,O}, state::S, sts::AbstractSpace{S}=states(pomdp))

"""
    actions{S,A,O}(pomdp::POMDP{S,A,O})

Returns the entire action space of a POMDP.
"""
@pomdp_func actions{S,A,O}(pomdp::POMDP{S,A,O})

"""
    actions{S,A,O}(pomdp::POMDP{S,A,O}, state::S, aspace::AbstractSpace{A})

Modifies aspace to the action space accessible from the given state and returns it.
"""
@pomdp_func actions{S,A,O}(pomdp::POMDP{S,A,O}, state::S, acts::AbstractSpace{A}=actions(pomdp))

"""
    actions{S,A,O}(pomdp::POMDP{S,A,O}, belief::Belief{S}, aspace::AbstractSpace{A})

Modifies aspace to the action space accessible from the states with nonzero belief and returns it.
"""
@pomdp_func actions{S,A,O}(pomdp::POMDP{S,A,O}, belief::Belief{S}, acts::AbstractSpace{A}=actions(pomdp))

"""
    observations{S,A,O}(pomdp::POMDP{S,A,O})

Returns the entire observation space.
"""
@pomdp_func observations{S,A,O}(pomdp::POMDP{S,A,O})

"""
    observations{S,A,O}(pomdp::POMDP{S,A,O}, state::S, obs::AbstractSpace{O}=observations(pomdp))

Modifies ospace to the observation space accessible from the given state and returns it.
"""
@pomdp_func observations{S,A,O}(pomdp::POMDP{S,A,O}, state::S, obs::AbstractSpace{O}=observations(pomdp))
