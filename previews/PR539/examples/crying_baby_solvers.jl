using BasicPOMCP
using NativeSARSOP

sarsop_solver = SARSOPSolver(; max_time=10.0)
sarsop_policy = POMDPs.solve(sarsop_solver, quick_crying_baby_pomdp)

pomcp_solver = POMCPSolver(; c=5.0, tree_queries=1000, rng=MersenneTwister(1))
pomcp_planner = POMDPs.solve(pomcp_solver, quick_crying_baby_pomdp)

struct HeuristicFeedPolicy{P<:POMDP} <: Policy
    pomdp::P
end
function POMDPs.updater(policy::HeuristicFeedPolicy)
    return DiscreteUpdater(policy.pomdp)
end
function POMDPs.action(policy::HeuristicFeedPolicy, b)
    if pdf(b, :hungry) > 0.5
        return :feed
    else
        return rand([:ignore, :sing])
    end
end

heuristic_policy = HeuristicFeedPolicy(quick_crying_baby_pomdp)
