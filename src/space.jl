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
    actions(m::Union{MDP,POMDP})

Returns the entire action space of a (PO)MDP.

---
    actions(m::Union{MDP,POMDP}, s)

Return the actions that can be taken from state `s`.

---
    actions(m::POMDP, b)

Return the actions that can be taken from belief `b`.

To implement an observation-dependent action space, use `currentobs(b)` to get the observation associated with belief `b` within the implementation of `actions(m, b)`.
"""
function actions end

actions(problem::Union{MDP,POMDP}, state) = actions(problem)
@impl_dep actions(::P,::S) where {P<:Union{POMDP,MDP},S} actions(::P)

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
