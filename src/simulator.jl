#################################################################
# The simulate function runs a simulation of a pomdp and returns
# the accumulated reward. Different behavior is defined by
# creating Simulator types
#################################################################

abstract Simulator

# runs a simulation
simulate(simulator::Simulator, pomdp::POMDP, policy::Policy) = error("No implementation of simulate for a simulator of type $(typeof(sim)), pomdp of type $(typeof(pomdp)), and policy of type $(typeof(policy))")
