#################################################################
# The simulate function runs a simulation of a pomdp and returns
# the accumulated reward. Different behavior is defined by
# creating Simulator types
#################################################################

# Base type for an object defining how a simulation should be carried out
abstract Simulator

# runs a simulation using the specified policy and returns the accumulated reward
@pomdp_func simulate(simulator::Simulator, pomdp::POMDP, policy::Policy, updater::BeliefUpdater, initial_belief::Belief)
