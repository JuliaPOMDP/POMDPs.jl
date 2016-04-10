#################################################################
# The policy is a mapping from a belief to an action in a POMDP,
# and it maps states to actions in an MDP. 
# The policy is extracted through calls to the action() function.
#################################################################

"""
Base type for a policy (a map from every possible belief, or more abstract policy state, to an optimal or suboptimal action)
"""
abstract Policy

"""
    create_action{S,A,O}(pomdp::POMDP{S,A,O})

Creates an action object (for preallocation purposes)
"""
@pomdp_func create_action{S,A,O}(pomdp::POMDP{S,A,O})
create_action{S,A<:Number,O}(pomdp::POMDP{S,A,O}) = zero(A)

"""
    action(p::Policy, state_or_belief, action)

Fills and returns action based on the current state or belief, given the policy
"""
@pomdp_func action(policy::Policy, state_or_belief, action)

"""
    action(policy::Policy, state_or_belief)

Returns an action for the current state or belief, given the policy

"""
@pomdp_func action(policy::Policy, state_or_belief)

# removed because of #70
#=
"""
    action{S,A}(p::Policy, b::Belief{S}, a::A)

Fills and returns action a for the current belief, given the policy
"""
@pomdp_func action{S,A}(p::Policy, b::Belief{S}, a::A)
=#

# removed because of #70
#=
"""
    action{S}(policy::Policy, belief::Belief{S})

Returns an action for the current belief, given the policy

"""
@pomdp_func action(p::Policy, b::Belief)
=#

"""
    updater(policy::Policy)

Returns a default BeliefUpdater appropriate for a belief type that policy `p` can use
"""
@pomdp_func updater(policy::Policy)

# removed because of #70
#=
"""
    value(p::Policy, belief::Belief)

Returns the utility value from policy p given the belief
"""
@pomdp_func value(p::Policy, belief::Belief)
=#

"""
    value{S}(p::Policy, state_or_belief)

Returns the utility value from policy p given the state
"""
@pomdp_func value(p::Policy, state_or_belief)
