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
states{S,A}(problem::Union{POMDP{S,A},MDP{S,A}}, s::S) = states(problem)
@impl_dep {P<:Union{POMDP,MDP},S} states(::P,::S) states(::P)

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
actions{S,A}(problem::Union{MDP{S,A},POMDP{S,A}}, state::S) = actions(problem)
@impl_dep {P<:Union{POMDP,MDP},S} actions(::P,::S) actions(::P)

"""
    actions{S,A,O,B}(problem::POMDP{S,A,O}, belief::B)

Return the action space accessible from the states with nonzero belief.
"""
actions{S,A,O,B}(problem::POMDP{S,A,O}, belief::B) = actions(problem)

"""
    observations(problem::POMDP)

Return the entire observation space.
"""
function observations end

"""
    observations{S,A,O}(problem::POMDP{S,A,O}, state::S)

Return the observation space accessible from the given state and returns it.
"""
observations{S,A,O}(problem::POMDP{S,A,O}, state::S) = observations(problem)
@impl_dep {P<:POMDP,S} observations(::P,::S) observations(::P)
