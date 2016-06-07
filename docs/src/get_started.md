## Getting Started

POMDPs serves as the interface used by a number of packages under the [JuliaPOMDP]() framework. It is essentially the
agreed upon API used by all the other packages in JuliaPOMDP. If you are using this framework, you may be trying to
accomplish one or more of the following three goals:

- Solve a decision or planning problem with stochastic dynamics (MDP) or partial observability (POMDP)
- Evaluate a solution in simulation
- Test your custom algorithm for solving MDPs or POMDPs against other state-of-the-art algorithms

If you are attempting to complete the first two goals, take a look at these Jupyer Notebook tutorials:

* [MDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/GridWorld.ipynb) for beginners gives an overview of using Value Iteration and Monte-Carlo Tree Search with the classic grid world problem
* [POMDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/Tiger.ipynb) gives an overview of using SARSOP and QMDP to solve the tiger problem

If you are trying to write your own algorithm for solving MDPs or POMDPs with this interface take a look at the API section of this guide.


The following snippet shows how a solver should be used to solve a problem and run a simulation.

```julia
using SARSOP
using POMDPModels

solver = SARSOP()

problem = BabyPOMDP()

policy = solve(solver, problem)
up = updater(policy)
sim = ReferenceSimulator(MersenneTwister(1), 10)

r = simulate(sim, problem, policy, up, initial_state_distribution(problem))

println("Reward: $r")
```
