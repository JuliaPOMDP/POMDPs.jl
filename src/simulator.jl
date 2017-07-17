#################################################################
# The simulate function runs a simulation of a pomdp and returns
# the accumulated reward. Different behavior is defined by
# creating Simulator types
#################################################################

"""
Base type for an object defining how simulations should be carried out.
"""
abstract type Simulator end

"""
    simulate{S,A,O,B}(simulator::Simulator, problem::POMDP{S,A,O}, policy::Policy{B}, updater::Updater{B}, initial_belief::B)
    simulate{S,A}(simulator::Simulator, problem::MDP{S,A}, policy::Policy, initial_state::S)

Run a simulation using the specified policy.

The return type is flexible and depends on the simulator. For example implementations, see the POMDPToolbox package.
"""
function simulate end
