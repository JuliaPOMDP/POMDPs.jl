# In src/policies/value_policy.jl or equivalent policy definitions

import POMDPs: updater, action

"""
    updater(policy::ValuePolicy{<:POMDP})

Return the default updater for a ValuePolicy in a POMDP, which is a DiscreteUpdater.
"""
updater(policy::ValuePolicy{<:POMDP}) = DiscreteUpdater(policy.pomdp)

"""
    action(policy::ValuePolicy{<:POMDP}, b)

Return the action for a ValuePolicy given a belief `b` in a POMDP.
"""
function action(policy::ValuePolicy{<:POMDP}, b)
    # Delegate to the underlying Q-value representation or QMDP policy logic
    return action(policy, mode(b)) # or QMDP-style argmax over expected Q values
end