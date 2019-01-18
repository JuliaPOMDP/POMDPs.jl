"""
Base type for an object defining how simulations should be carried out.
"""
abstract type Simulator end

"""
    simulate(sim::Simulator, m::POMDP, p::Policy, u::Updater=updater(p), b0=initialstate_distribution(m), s0=initialstate(m, rng))
    simulate(sim::Simulator, m::MDP, p::Policy, s0=initialstate(m, rng))

Run a simulation using the specified policy.

The return type is flexible and depends on the simulator. Simulations should adhere to the [Simulation Standard](http://juliapomdp.github.io/POMDPs.jl/latest/simulation.html#Simulation-Standard-1).
"""
function simulate end
