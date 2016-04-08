#################################################################
# The policy is a mapping from a belief to an action in a POMDP,
# and it maps states to actions in an MDP. 
# The policy is extracted through calls to the action() function.
#################################################################

"""
Base type for a policy (a map from every possible belief, or more abstract policy state, to an optimal or suboptimal action)
"""
abstract Policy{S,A,O}

"""
    create_action{S,A,O}(pomdp::POMDP{S,A,O})

Creates an action object (for preallocation purposes)
"""
@pomdp_func create_action{S,A,O}(pomdp::POMDP{S,A,O})
create_action{S,A<:Number,O}(pomdp::POMDP{S,A,O}) = zero(A)

"""
    action{S,A,O}(p::Policy{S,A,O}, s::S, a::A)

Fills and returns action a for the current state, given the policy
"""
@pomdp_func action{S,A,O}(p::Policy{S,A,O}, s::S, a::A)

"""
    action(policy::Policy, s::State)

Returns an action for the current state, given the policy

"""
@pomdp_func action{S,A,O}(p::Policy{S,A,O}, s::S)

"""
    action{S,A,O}(p::Policy{S,A,O}, b::Belief{S}, a::A)

Fills and returns action a for the current belief, given the policy
"""
@pomdp_func action{S,A,O}(p::Policy{S,A,O}, b::Belief{S}, a::A)

"""
    action{S,A,O}(policy::Policy{S,A,O}, belief::Belief{S})

Returns an action for the current belief, given the policy

"""
@pomdp_func action{S,A,O}(p::Policy{S,A,O}, b::Belief{S})

"""
    updater{S,A,O}(policy::Policy{S,A,O})

Returns a default BeliefUpdater appropriate for a belief type that policy `p` can use
"""
@pomdp_func updater{S,A,O}(policy::Policy{S,A,O})

"""
    value{S,A,O}(p::Policy{S,A,O}, belief::Belief{S})

Returns the utility value from policy p given the belief
"""
@pomdp_func value{S,A,O}(p::Policy{S,A,O}, belief::Belief{S})

"""
    value{S,A,O}(p::Policy{S,A,O}, state::S)

Returns the utility value from policy p given the state
"""
@pomdp_func value{S,A,O}(p::Policy{S,A,O}, state::S)
