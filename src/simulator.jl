#################################################################
# The simulate function runs a simulation of a pomdp and returns
# the accumulated reward. Different behavior is defined by
# creating Simulator types
#################################################################

abstract Simulator

# runs a simulation
@pomdp_func simulate(simulator::Simulator, pomdp::POMDP, policy::Policy, updater::BeliefUpdater, initial_belief::Belief)
