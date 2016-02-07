#################################################################
# The simulate function runs a simulation of a pomdp and returns
# the accumulated reward. Different behavior is defined by
# creating Simulator types
#################################################################

# Base type for an object defining how a simulation should be carried out
abstract Simulator{S,A,O}

# runs a simulation using the specified policy and returns the accumulated reward
@pomdp_func simulate{S,A,O}(simulator::Simulator{S,A,O}, pomdp::POMDP{S,A,O}, policy::Policy{S,A,O}, updater::BeliefUpdater{S,A,O}, initial_belief::Belief{S})
