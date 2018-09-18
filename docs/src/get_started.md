# Getting Started

Before writing our own POMDP problems or solvers, let's try out some of the available solvers and problem models
available in JuliaPOMDP.

Here is a short piece of code that solves the Tiger POMDP using QMDP, and evaluates the results. Note that you must
have the QMDP, POMDPModels, and POMDPToolbox modules installed.

```julia
using QMDP, POMDPModels, POMDPSimulators

# initialize problem and solver
pomdp = TigerPOMDP() # from POMDPModels
solver = QMDPSolver() # from QMDP

# compute a policy
policy = solve(solver, pomdp)

#evaluate the policy
belief_updater = updater(policy) # the default QMPD belief updater (discrete Bayesian filter)
init_dist = initialstate_distribution(pomdp) # from POMDPModels
hr = HistoryRecorder(max_steps=100) # from POMDPSimulators
hist = simulate(hr, pomdp, policy, belief_updater, init_dist) # run 100 step simulation
println("reward: $(discounted_reward(hist))")
```

The first part of the code loads the desired packages and initializes the problem and the solver. Next, we compute a
POMDP policy. Lastly, we evaluate the results.

There are a few things to mention here. First, the TigerPOMDP type implements all the functions required by
QMDPSolver to compute a policy. Second, each policy has a default updater (essentially a filter used to update the
belief of the POMDP). To learn more about Updaters check out the [Concepts](http://juliapomdp.github.io/POMDPs.jl/latest/concepts/) section.
