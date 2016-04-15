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
    create_action(problem::POMDP)
    create_action(problem::MDP)

Creates an action object (for preallocation purposes)
"""
@pomdp_func create_action(problem::Union{POMDP,MDP})

# default implementation for numeric types
create_action{S,A<:Number}(problem::Union{POMDP{S,A},MDP{S,A}}) = zero(A)

"""
    action(p::Policy, x::Any, action)
    action(p::Policy, x::Belief, action)

Fills and returns action based on the current state or belief, given the policy.

If an MDP is being simulated, x will be a state; if a POMDP is being simulated, x will be a Belief
"""
@pomdp_func action(policy::Policy, x::Any, action::Any)

"""
    action(policy::Policy, x::Any)
    action(policy::Policy, x::Belief)

Returns an action for the current state or belief, given the policy

If an MDP is being simulated, x will be a state; if a POMDP is being simulated, x will be a Belief
"""
@pomdp_func action(policy::Policy, x::Any)


"""
    updater(policy::Policy)

Returns a default BeliefUpdater appropriate for a belief type that policy `p` can use
"""
@pomdp_func updater(policy::Policy)

"""
    value{S}(p::Policy, x::Any)
    value{S}(p::Policy, x::Belief)

Returns the utility value from policy p given the state
"""
@pomdp_func value(p::Policy, x::Any)
