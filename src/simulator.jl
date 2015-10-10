#################################################################
# The simulate function runs a simulation of a pomdp and returns
# the accumulated reward. Different behavior is defined by
# creating Simulator types
#################################################################

abstract Simulator

# runs a simulation
simulate(simulator::Simulator, pomdp::POMDP, policy::Policy, updater::BeliefUpdater, initial_belief::Belief) = error("No implementation of simulate for simulator::$(typeof(simulator)), pomdp::$(typeof(pomdp)), and policy::$(typeof(policy)), updater::$(typeof(updater))")
