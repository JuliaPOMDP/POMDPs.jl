# Getting Started

Before writing our own POMDP problems or solvers, let's try out some of the available solvers and problem models
available in JuliaPOMDP.

Here is a short piece of code that solves the Tiger POMDP using SARSOP, and evaluates the results. Note that you must
have the SARSOP, POMDPModels, and POMDPToolbox modules installed.

```julia
using SARSOP, POMDPModels, POMDPToolbox

# initialize problem and solver
pomdp = TigerPOMDP() # from POMDPModels
solver = SARSOPSolver() # from SARSOP

# compute a policy
policy = solve(solver, pomdp)

#evaluate the policy
belief_updater = updater(policy) # the default QMPD belief updater (discrete Bayesian filter)
init_dist = initial_state_distribution(pomdp) # from POMDPModels
hist = HistoryRecorder(max_steps=100) # from POMDPToolbox
r = simulate(hist, pomdp, policy, belief_updater, init_dist) # run 100 step simulation
```

The first part of the code loads the desired packages and initializes the problem and the solver. Next, we compute a
POMDP policy. Lastly, we evaluate the results.

There are a few things to mention here. First, the TigerPOMDP type implements all the functions required by
SARSOPSolver to compute a policy. Second, each policy has a default updater (essentially a filter used to update the
belief of the POMDP). To learn more about Updaters check out the [Concepts](http://juliapomdp.github.io/POMDPs.jl/latest/concepts/) section.




