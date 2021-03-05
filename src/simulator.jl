"""
Base type for an object defining how simulations should be carried out.
"""
abstract type Simulator end

"""
    simulate(sim::Simulator, m::POMDP, p::Policy, u::Updater=updater(p), b0=initialstate(m), s0=rand(b0))
    simulate(sim::Simulator, m::MDP, p::Policy, s0=rand(initialstate(m)))

Run a simulation using the specified policy.

The return type is flexible and depends on the simulator. Simulations should adhere to the [Simulation Standard](http://juliapomdp.github.io/POMDPs.jl/latest/simulation.html#Simulation-Standard-1).
"""
function simulate end
