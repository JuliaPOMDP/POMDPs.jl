# Using Different Solvers
There are various solvers implemented for use out-of-the-box. Please reference the repository README for a list of [MDP Solvers](https://github.com/JuliaPOMDP/POMDPs.jl?tab=readme-ov-file#mdp-solvers) and [POMDP Solvers](https://github.com/JuliaPOMDP/POMDPs.jl?tab=readme-ov-file#pomdp-solvers) implemented and maintained by the JuliaPOMDP community. We provide a few examples of how to use a small subset of these solvers.

```@setup crying_sim
include("examples/crying_baby_examples.jl")
```

## Checking Requirements
Before using a solver, it is prudent to ensure the problem meets the requirements of the solver. Please reference the solver documentation for detailed information about the requirements of each solver. 

We can use [POMDPLInter](https://github.com/JuliaPOMDP/POMDPLinter.jl) to help us determine if we have all of the required components defined for a particular solver. However, not all solvers have the requirements implemented. If/when you encounter a solver that does not have the requirements implemented, please open an issue on the solver's repository.

Let's check if we have all of the required components of our problems for the QMDP solver.

```@example crying_sim
using POMDPLinter
using QMDP

qmdp_solver = QMDPSolver()

println("Quick Crying Baby POMDP")
@show_requirements POMDPs.solve(qmdp_solver, quick_crying_baby_pomdp)

println("\nExplicit Crying Baby POMDP")
@show_requirements POMDPs.solve(qmdp_solver, explicit_crying_baby_pomdp)

println("\nTabular Crying Baby POMDP")
@show_requirements POMDPs.solve(qmdp_solver, tabular_crying_baby_pomdp)

println("\nGen Crying Baby POMDP")
# We don't have an actions(::GenGryingBabyPOMDP) implemented
try
    @show_requirements POMDPs.solve(qmdp_solver, gen_crying_baby_pomdp)
catch err_msg
    println(err_msg)
end
```

## Offline (SARSOP)
In this example, we will use the [NativeSARSOP](https://github.com/JuliaPOMDP/NativeSARSOP.jl) solver. The process for generating offline polcies is similar for all offline solvers. First, we define the solver with the desired parameters. Then, we call `POMDPs.solve` with the solver and the problem. We can query the policy using the `action` function.

```@example crying_sim
using NativeSARSOP

# Define the solver with the desired paramters
sarsop_solver = SARSOPSolver(; max_time=10.0)

# Solve the problem by calling POMDPs.solve. SARSOP will compute the policy and return an `AlphaVectorPolicy`
sarsop_policy = POMDPs.solve(sarsop_solver, quick_crying_baby_pomdp)

# We can query the policy using the `action` function
b = initialstate(quick_crying_baby_pomdp)
a = action(sarsop_policy, b)

@show a

```

## Online (POMCP)
For the online solver, we will use Particle Monte Carlo Planning ([POMCP](https://github.com/JuliaPOMDP/BasicPOMCP.jl)). For online solvers, we first define the solver similar to offline solvers. However, when we call `POMDPs.solve`, we are returned an online plannner. Similar to the offline solver, we can query the policy using the `action` function and that is when the online solver will compute the action.

```@example crying_sim
using BasicPOMCP

pomcp_solver = POMCPSolver(; c=5.0, tree_queries=1000, rng=MersenneTwister(1))
pomcp_planner = POMDPs.solve(pomcp_solver, quick_crying_baby_pomdp)

b = initialstate(quick_crying_baby_pomdp)
a = action(pomcp_planner, b)

@show a

```

## Heuristic Policy
While we often want to use a solver to compute a policy, sometimes we might want to use a heuristic policy. For example, we may want to use a heuristic policy during our rollouts for online solvers or to use as a baseline. In this example, we will define a simple heuristic policy that feeds the baby if our belief of the baby being hungry is greater than 50%, otherwise we will randomly ignore or sing to the baby.

```@example crying_sim
struct HeuristicFeedPolicy{P<:POMDP} <: Policy
    pomdp::P
end

# We need to implement the action function for our policy
function POMDPs.action(policy::HeuristicFeedPolicy, b)
    if pdf(b, :hungry) > 0.5
        return :feed
    else
        return rand([:ignore, :sing])
    end
end

# Let's also define the default updater for our policy
function POMDPs.updater(policy::HeuristicFeedPolicy)
    return DiscreteUpdater(policy.pomdp)
end

heuristic_policy = HeuristicFeedPolicy(quick_crying_baby_pomdp)

# Let's query the policy a few times
b = SparseCat([:sated, :hungry], [0.1, 0.9])
a1 =  action(heuristic_policy, b)

b = SparseCat([:sated, :hungry], [0.9, 0.1])
a2 = action(heuristic_policy, b)

@show [a1, a2]

```