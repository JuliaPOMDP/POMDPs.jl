#################################################################
# The policy is a mapping from a belief to an action in a POMDP,
# and it maps states to actions in an MDP. 
# The policy is extracted through calls to the action() function.
#################################################################

abstract Policy{S,A,O}

# creates an action object (for preallocation purposes)
#@pomdp_func create_action{S,A,O}(pomdp::POMDP{S,A,O})

# returns a default BeliefUpdater appropriate for a belief type that policy `p` can use
@pomdp_func action{S,A,O}(p::Policy{S,A,O}, s::S, a::A)
@pomdp_func action{S,A,O}(p::Policy{S,A,O}, s::S)
@pomdp_func action{S,A,O}(p::Policy{S,A,O}, b::Belief{S}, a::A)
@pomdp_func action{S,A,O}(p::Policy{S,A,O}, b::Belief{S})

# returns a default BeliefUpdater appropriate for a belief type that policy `p` can use
@pomdp_func updater{S,A,O}(policy::Policy{S,A,O})

# returns the utility value from policy p given the belief
@pomdp_func value{S,A,O}(p::Policy{S,A,O}, belief::Belief{S})
# returns the utility value from policy p given the state
@pomdp_func value{S,A,O}(p::Policy{S,A,O}, state::S)
