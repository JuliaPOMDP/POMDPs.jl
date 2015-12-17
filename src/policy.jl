#################################################################
# The policy is a mapping from a belief to an action in a POMDP,
# and it maps states to actions in an MDP. 
# The policy is extracted through calls to the action() function.
#################################################################

abstract Policy

# creates an action object (for preallocation purposes)
@pomdp_func create_action(pomdp::POMDP)

# returns a default BeliefUpdater appropriate for a belief type that policy `p` can use
@pomdp_func action(p::Policy, s::State, a::Action)
@pomdp_func action(p::Policy, s::State)
@pomdp_func action(p::Policy, b::Belief, a::Action)
@pomdp_func action(p::Policy, b::Belief)

# returns a default BeliefUpdater appropriate for a belief type that policy `p` can use
@pomdp_func updater(policy::Policy)

# returns the utility value from policy p given the belief
@pomdp_func value(p::Policy, belief::Belief)
# returns the utility value from policy p given the state
@pomdp_func value(p::Policy, state::State)
