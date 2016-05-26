#################################################################
# The simulate function runs a simulation of a pomdp and returns
# the accumulated reward. Different behavior is defined by
# creating Simulator types
#################################################################

"""
Base type for an object defining how a simulation should be carried out
"""
abstract Simulator

"""
    simulate{S,A,O,B}(simulator::Simulator, problem::POMDP{S,A,O}, policy::Policy{B}, updater::Updater{B}, initial_belief::Union{B,AbstractDistribution{S}}) 

Run a simulation using the specified policy and returns the accumulated reward
"""
@pomdp_func simulate(simulator::Simulator, problem::POMDP, policy::Policy, updater::Updater, initial_belief::Any)

"""
    simulate{S,A}(simulator::Simulator, problem::MDP{S,A}, policy::Policy, initial_state::S) 

Run a simulation using the specified policy and returns the accumulated reward
"""
@pomdp_func simulate{S,A}(simulator::Simulator, problem::MDP{S,A}, policy::Policy, initial_state::S)
