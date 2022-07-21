"""
    PolicyWrapper

Flexible utility wrapper for a policy designed for collecting statistics about planning.

Carries a function, a policy, and optionally a payload (that can be any type).

The function should typically be defined with the do syntax. Each time `action` is called on the wrapper, this function will be called.

If there is no payload, it will be called with two argments: the policy and the state/belief. If there is a payload, it will be called with three arguments: the policy, the payload, and the current state or belief. The function should return an appropriate action. The idea is that, in this function, `action(policy, s)` should be called, statistics from the policy/planner should be collected and saved in the payload, exceptions can be handled, and the action should be returned.

Constructor

`PolicyWrapper(policy::Policy; payload=nothing)`

# Example
```julia
using POMDPModels
using POMDPToolbox

mdp = GridWorld()
policy = RandomPolicy(mdp)
counts = Dict(a=>0 for a in actions(mdp))

# with a payload
statswrapper = PolicyWrapper(policy, payload=counts) do policy, counts, s
    a = action(policy, s)
    counts[a] += 1
    return a
end

h = simulate(HistoryRecorder(max_steps=100), mdp, statswrapper)
for (a, count) in payload(statswrapper)
    println("policy chose action \$a \$count of \$(n_steps(h)) times.")
end

# without a payload
errwrapper = PolicyWrapper(policy) do policy, s
    try
        a = action(policy, s)
    catch ex
        @warn("Caught error in policy; using default")
        a = :left
    end
    return a
end

h = simulate(HistoryRecorder(max_steps=100), mdp, errwrapper)
```

# Fields 
- `f::F`
- `policy::P`
- `payload::PL`

"""
mutable struct PolicyWrapper{P<:Policy, F<:Function, PL} <: Policy
    f::F
    policy::P
    payload::PL
end

function PolicyWrapper(f::Function, policy::Policy; payload=nothing)
    return PolicyWrapper(f, policy, payload)
end

function PolicyWrapper(policy::Policy; payload=nothing)
    return PolicyWrapper((p,s)->action(p.policy,s), policy, payload)
end

function action(p::PolicyWrapper, s)
    if p.payload == nothing
        return p.f(p.policy, s)
    else
        return p.f(p.policy, p.payload, s)
    end
end

updater(p::PolicyWrapper) = updater(p.policy)

payload(p::PolicyWrapper) = p.payload

Random.seed!(p::PolicyWrapper, seed) = seed!(p.policy, seed)
