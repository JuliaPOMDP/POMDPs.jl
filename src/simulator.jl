"""
Base type for an object defining how simulations should be carried out.
"""
abstract type Simulator end

"""
    simulate(simulator::Simulator, problem::POMDP{S,A,O}, policy::Policy, updater::Updater, initial_belief, initial_state::S)
    simulate(simulator::Simulator, problem::MDP{S,A}, policy::Policy, initial_state::S)

Run a simulation using the specified policy.

The return type is flexible and depends on the simulator. Simulations should adhere to the [Simulation Standard](http://juliapomdp.github.io/POMDPs.jl/latest/simulation.html#Simulation-Standard-1).
"""
function simulate end
