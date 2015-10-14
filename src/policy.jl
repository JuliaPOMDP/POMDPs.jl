#################################################################
# The policy is a mapping from a belief to an action in a POMDP,
# and it maps states to actions in an MDP. 
# The policy is extracted through calls to the action() function.
#################################################################

abstract Policy

# initializes the MDP/POMDP action
@pomdp_func create_action(pomdp::POMDP)

# returns the action according to policy p given the state
@pomdp_func action(p::Policy, state::State, action=create_action(pomdp))

# returns a BeliefUpdater appropriate for the policy
@pomdp_func updater(policy::Policy)

# returns the utility value from policy p given the belief
@pomdp_func value(p::Policy, belief::Belief)
# returns the utility value from policy p given the state
@pomdp_func value(p::Policy, state::State)
