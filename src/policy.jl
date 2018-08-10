#################################################################
# The policy is a mapping from a belief to an action in a POMDP,
# and it maps states to actions in an MDP.
# The policy is extracted through calls to the action() function.
#################################################################

"""
Base type for a policy (a map from every possible belief, or more abstract policy state, to an optimal or suboptimal action)
"""
abstract type Policy end

"""
    action{B}(policy::Policy, x::B)

Fills and returns action based on the current state or belief, given the policy.
`B` is a generalized information state - can be a state in an MDP, a distribution in POMDP,
or any other representation needed to make a decision using the given policy.
"""
function action end

"""
    updater(policy::Policy)

Returns a default Updater appropriate for a belief type that policy `p` can use
"""
function updater end

"""
    value(p::Policy, s)
    value(p::Policy, s, a)

Returns the utility value from policy `p` given the state (or belief), or state-action (or belief-action) pair.

The state-action version is commonly referred to as the Q-value.
"""
function value end
