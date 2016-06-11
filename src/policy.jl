#################################################################
# The policy is a mapping from a belief to an action in a POMDP,
# and it maps states to actions in an MDP. 
# The policy is extracted through calls to the action() function.
#################################################################

"""
Base type for a policy (a map from every possible belief, or more abstract policy state, to an optimal or suboptimal action)

    B: a belief (or policy state) that represents the knowledge an agent has about the state of the system
"""
abstract Policy{B}

"""
    create_action(problem::POMDP)
    create_action(problem::MDP)

Creates an action object (for preallocation purposes)
"""
@pomdp_func create_action(problem::Union{POMDP,MDP})

# default implementation for numeric types
create_action{S,A<:Number}(problem::Union{POMDP{S,A},MDP{S,A}}) = zero(A)

"""
    action{B}(p::Policy, x::B, action)

Fills and returns action based on the current state or belief, given the policy.
`B` is a generalized information state - can be a state in an MDP, a distribution in POMDP,
or any other representation needed to make a decision using the given policy. 
"""
@pomdp_func action{B,A}(policy::Policy, x::B, action::A)

"""
    action{B}(policy::Policy, x::B)

Returns an action for the current state or belief, given the policy

If an MDP is being simulated, `x` will be a state; if a POMDP is being simulated, `x` will be a belief
"""
@pomdp_func action{B}(policy::Policy, x::B)


"""
    updater(policy::Policy)

Returns a default Updater appropriate for a belief type that policy `p` can use
"""
@pomdp_func updater(policy::Policy)

"""
    value{B}(p::Policy, x::B)

Returns the utility value from policy `p` given the state
"""
@pomdp_func value{B}(p::Policy, x::B)
