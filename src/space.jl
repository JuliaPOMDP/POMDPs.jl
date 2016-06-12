#################################################################
# This file defines an abstract type to represent spaces and abstract functions to specify the spaces
# AbstractSpace: the abstract super type for the state, action and observation spaces
#################################################################

"""
Base type for state, action and observation spaces.
    
    T: type that parametrizes the space (state, action, or observation)
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

"""
    states(problem::POMDP)
    states(problem::MDP)
    
Returns the complete state space of a POMDP. 
"""
@pomdp_func states(problem::Union{POMDP,MDP})

"""
    states{S,A,O}(problem::POMDP{S,A,O}, state::S)
    states{S,A}(problem::MDP{S,A}, state::S)
    
Returns a subset of the state space reachable from `state`. 
"""
states{S,A}(problem::Union{POMDP{S,A},MDP{S,A}}, s::S, sts::AbstractSpace{S}=states(problem)) = sts

"""
    actions(problem::POMDP)
    actions(problem::MDP)

Returns the entire action space of a POMDP.
"""
@pomdp_func actions(problem::Union{POMDP,MDP})

"""
    actions{S,A,O}(problem::POMDP{S,A,O}, state::S, aspace::AbstractSpace{A})
    actions{S,A}(problem::MDP{S,A}, state::S, aspace::AbstractSpace{A})

Modifies `aspace` to the action space accessible from the given state and returns it.
"""
actions{S,A}(problem::Union{MDP{S,A},POMDP{S,A}}, state::S, acts::AbstractSpace{A}=actions(problem)) = acts

"""
    actions{S,A,O,B}(problem::POMDP{S,A,O}, belief::B, aspace::AbstractSpace{A})

Modifies `aspace` to the action space accessible from the states with nonzero belief and returns it.
"""
@pomdp_func actions{S,A,O,B}(problem::POMDP{S,A,O}, belief::B, acts::AbstractSpace{A}=actions(problem))

"""
    observations(problem::POMDP)

Returns the entire observation space.
"""
@pomdp_func observations(problem::POMDP)

"""
    observations{S,A,O}(problem::POMDP{S,A,O}, state::S, obs::AbstractSpace{O}=observations(problem))

Modifies `obs` to the observation space accessible from the given state and returns it.
"""
observations{S,A,O}(problem::POMDP{S,A,O}, state::S, obs::AbstractSpace{O}=observations(problem)) = obs
