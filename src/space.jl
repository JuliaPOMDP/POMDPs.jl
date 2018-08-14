######################
# interface for spaces
######################

"""
    dimensions(s::Any)

Returns the number of dimensions in space `s`.
"""
function dimensions end

"""
    states(problem::POMDP)
    states(problem::MDP)
    
Returns the complete state space of a POMDP. 
"""
function states end

"""
    states{S,A,O}(problem::POMDP{S,A,O}, state::S)
    states{S,A}(problem::MDP{S,A}, state::S)
    
Returns a subset of the state space reachable from `state`. 
"""
states(problem::Union{POMDP,MDP}, s) = states(problem)
@impl_dep states(::P,::S) where {P<:Union{POMDP,MDP},S} states(::P)

"""
    actions(problem::POMDP)
    actions(problem::MDP)

Returns the entire action space of a POMDP.
"""
function actions end

"""
    actions{S,A,O}(problem::POMDP{S,A,O}, state::S)
    actions{S,A}(problem::MDP{S,A}, state::S)

Return the action space accessible from the given state.
"""
actions(problem::Union{MDP,POMDP}, state) = actions(problem)
@impl_dep actions(::P,::S) where {P<:Union{POMDP,MDP},S} actions(::P)

"""
    actions(problem::POMDP, belief)

Return the action space accessible from the states with nonzero belief.
"""
actions(problem::POMDP, belief) = actions(problem)

"""
    observations(problem::POMDP)

Return the entire observation space.
"""
function observations end

"""
    observations{S,A,O}(problem::POMDP{S,A,O}, state::S)

Return the observation space accessible from the given state and returns it.
"""
observations(problem::POMDP, state) = observations(problem)
@impl_dep observations(::P,::S) where {P<:POMDP,S} observations(::P)
