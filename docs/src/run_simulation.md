# Running Simulations

Running a simulation consists of two steps, creating a simulator and calling the [`simulate`](@ref) function. For example, given a POMDP or MDP model `m`, and a policy `p`, one can use the [`Rollout Simulator`](https://juliapomdp.github.io/POMDPSimulators.jl/latest/rollout.html) from the [POMDPSimulators package](https://github.com/JuliaPOMDP/POMDPSimulators.jl) to find the accumulated discounted reward from a single simulated trajectory as follows:

```julia
sim = RolloutSimulator()
r = simulate(sim, m, p)
```

More inputs, such as a belief updater, initial state, initial belief, etc. may be specified as arguments to [`simulate`](@ref). See the docstring for [`simulate`](@ref) and the appropriate "Input" sections in the [Simulation Standard](@ref) page for more information.

More examples can be found in the [POMDPExamples package](https://github.com/JuliaPOMDP/POMDPExamples.jl). A variety of simulators that return more information and interact in different ways can be found in the [POMDPSimulators package](https://github.com/JuliaPOMDP/POMDPSimulators.jl).
