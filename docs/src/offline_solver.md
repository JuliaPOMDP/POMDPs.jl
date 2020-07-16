# Example: Defining an offline solver

In this example, we will define a simple [offline solver](@ref Online-and-Offline-Solvers) that works for both POMDPs and MDPs. In order to focus on the code structure, we will not create an algorithm that finds an optimal policy, but rather a *greedy policy*, that is, one that optimizes the expected immediate reward. For information on using this solver in a simulation, see [Running Simulations](@ref).

We begin by creating a solver type. Since there are no adjustable parameters for the solver, it is an empty type, but for a more complex solver, parameters would usually be included as type fields.

```jldoctest offline; output=false
using POMDPs

struct GreedyOfflineSolver <: Solver end

# output

```

Next, we define the functions that will make the solver work for both MDPs and POMDPs.

### MDP Case

Finding a greedy policy for an MDP consists of determining the action that has the best reward for each state. First, we create a simple policy object that holds a greedy action for each state.

```jldoctest offline; output=false
struct DictPolicy{S,A} <: Policy
    actions::Dict{S,A}
end

POMDPs.action(p::DictPolicy, s) = p.actions[s]

# output

```

!!! note
    A `POMDPPolicies.VectorPolicy` could be used here. We include this example to show how to define a custom policy.

The solve function calculates the best greedy action for each state and saves it in a policy. To have the widest possible compatibility with POMDP models, we want to use [`reward`](@ref)`(m, s, a, sp)` instead of [`reward`](@ref)`(m, s, a)`, which means we need to calculate the expectation of the reward over transitions to every possible next state.

```jldoctest offline; output=false
function POMDPs.solve(::GreedyOfflineSolver, m::MDP)

    best_actions = Dict{statetype(m), actiontype(m)}()

    for s in states(m)
        if !isterminal(m, s)
            best = -Inf
            for a in actions(m)
                td = transition(m, s, a)
                r = 0.0
                for sp in support(td)
                    r += pdf(td, sp) * reward(m, s, a, sp)
                end
                if r >= best
                    best_actions[s] = a
                end
            end
        end
    end
    
    return DictPolicy(best_actions)
end

# output

```

!!! note
    We limited this implementation to using basic POMDPs.jl implementation functions, but tools such as `POMDPModelTools.StateActionReward`, `POMDPModelTools.ordered_states`, and `POMDPModelTools.weighted_iterator` could have been used for a more concise and efficient implementation.

We can now verify whether the policy produces the greedy action on an example from POMDPModels:

```jldoctest offline
using POMDPModels

gw = SimpleGridWorld(size=(2,1), rewards=Dict(GWPos(2,1)=>1.0))
policy = solve(GreedyOfflineSolver(), gw)

action(policy, GWPos(1,1))

# output

:right
```

### POMDP Case

For a POMDP, the greedy solution is the action that maximizes the expected immediate reward according to the belief. Since there are an infinite number of possible beliefs, the greedy solution for every belief cannot be calculated online. However, the greedy policy can take the form of an alpha vector policy where each action has an associated alpha vector with each entry corresponding to the immediate reward from taking the action in that state.

Again, because a POMDP, may have [`reward`](@ref)`(m, s, a, sp, o)` instead of [`reward`](@ref)`(m, s, a)`, we use the former and calculate the expectation over all next states and observations.

```jldoctest offline; output=false
import POMDPPolicies

function POMDPs.solve(::GreedyOfflineSolver, m::POMDP)

    alphas = Vector{Float64}[]

    for a in actions(m)
        alpha = zeros(length(states(m)))
        for s in states(m)
            if !isterminal(m, s)
                r = 0.0
                td = transition(m, s, a)
                for sp in support(td)
                    tp = pdf(td, sp)
                    od = observation(m, s, a, sp)
                    for o in support(od)
                        r += tp * pdf(od, o) * reward(m, s, a, sp, o)
                    end
                end
                alpha[stateindex(m, s)] = r
            end
        end
        push!(alphas, alpha)
    end
    
    return POMDPPolicies.AlphaVectorPolicy(m, alphas, collect(actions(m)))
end

# output

```
We can now verify that a policy created by the solver determines the correct greedy actions:

```jldoctest offline; output=false
using POMDPModels
using POMDPModelTools # for Deterministic, Uniform

tiger = TigerPOMDP()
policy = solve(GreedyOfflineSolver(), tiger)

@assert action(policy, Deterministic(TIGER_LEFT)) == TIGER_OPEN_RIGHT
@assert action(policy, Deterministic(TIGER_RIGHT)) == TIGER_OPEN_LEFT
@assert action(policy, Uniform(states(tiger))) == TIGER_LISTEN

# output

```
