# Example: Defining an online solver

In this example, we will define a simple [online solver](@ref Online-and-Offline-Solvers) that works for both POMDPs and MDPs. In order to focus on the code structure, we will not create an algorithm that finds an optimal policy, but rather a *greedy policy*, that is, one that optimizes the expected immediate reward. For information on using this solver in a simulation, see [Running Simulations](@ref).

In order to handle the widest range of problems, we will use [`@gen`](@ref) to generate Mone Carlo samples to estimate the reward even if only a simulator is available. We begin by creating the necessary types and the solve function. The only solver parameter is the number of samples used to estimate the reward at each step.

```jldoctest online; output=false
using POMDPs

struct MonteCarloGreedySolver <: Solver
    num_samples::Int
end

struct MonteCarloGreedyPlanner{M} <: Policy
    m::M
    num_samples::Int
end

POMDPs.solve(sol::MonteCarloGreedySolver, m) = MonteCarloGreedyPlanner(m, sol.num_samples)

# output

```

Next, we define the [`action`](@ref) function where the online work takes place.

### MDP Case

```jldoctest online; output=false
function POMDPs.action(p::MonteCarloGreedyPlanner{<:MDP}, s)
    best_reward = -Inf
    local best_action
    for a in actions(p.m)
        reward_sum = sum(@gen(:r)(p.m, s, a) for _ in 1:p.num_samples)
        if reward_sum >= best_reward
            best_reward = reward_sum
            best_action = a
        end
    end
    return best_action
end

# output

```

### POMDP Case

```jldoctest online
function POMDPs.action(p::MonteCarloGreedyPlanner{<:POMDP}, b)
    best_reward = -Inf
    local best_action
    for a in actions(p.m)
        s = rand(b)
        reward_sum = sum(@gen(:r)(p.m, s, a) for _ in 1:p.num_samples)
        if reward_sum >= best_reward
            best_reward = reward_sum
            best_action = a
        end
    end
    return best_action
end

# output

```

### Verification

We can now verify that the online planner works in some simple cases:

```jldoctest online
using POMDPModels

gw = SimpleGridWorld(size=(2,1), rewards=Dict(GWPos(2,1)=>1.0))
solver = MonteCarloGreedySolver(1000)
planner = solve(solver, gw)

action(planner, GWPos(1,1))

# output

:right
```

```jldoctest online; output=false
using POMDPModels
using POMDPModelTools # for Deterministic, Uniform

tiger = TigerPOMDP()
solver = MonteCarloGreedySolver(1000)

planner = solve(solver, tiger)

@assert action(planner, Deterministic(TIGER_LEFT)) == TIGER_OPEN_RIGHT
@assert action(planner, Deterministic(TIGER_RIGHT)) == TIGER_OPEN_LEFT
# note action(planner, Uniform(states(tiger))) is not very reliable with this number of samples

# output

```
