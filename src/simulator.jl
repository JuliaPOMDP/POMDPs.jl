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
    simulate{S,A,O}(simulator::Simulator, pomdp::POMDP{S,A,O}, policy::Policy{S,A,O}, updater::BeliefUpdater{S,A,O}, initial_belief::Belief{S}) 

Runs a simulation using the specified policy and returns the accumulated reward
"""
@pomdp_func simulate{S,A,O}(simulator::Simulator, pomdp::POMDP{S,A,O}, policy::Policy, updater::BeliefUpdater, initial_belief::Belief) # Note: I got rid of the parameters for BeliefUpdater and Belief to resolve conflicting definition errors
