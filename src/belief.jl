#################################################################
######################## BELIEF #################################
#################################################################
# The abstract Belief type implements initialization (initial_belief and create_belief)
# and update (belief) methods for POMDP beliefs.
# For discrete problems, it can be usually be represented as a vector.
# For tools supportng belief updates see POMDPToolbox.jl

abstract Belief{T} <: AbstractDistribution{T}
abstract BeliefUpdater{S,A,O}

# returns an example initial belief for the pomdp
@pomdp_func initial_belief{S,A,O}(pomdp::POMDP{S,A,O}, belief::Belief{S} = create_belief(pomdp))

# allocates and returns an empty problem-native belief structure
@pomdp_func create_belief{S,A,O}(pomdp::POMDP{S,A,O})

# creates a belief object of the type used by `updater` (for preallocation purposes)
@pomdp_func create_belief{S,A,O}(updater::BeliefUpdater{S,A,O})

# updates the belief given the old belief (belief_old), the action and the observation
@pomdp_func update{S,A,O}(updater::BeliefUpdater{S,A,O}, belief_old::Belief{S}, action::A, obs::O, belief_new::Belief{S}=create_belief(updater))

# returns a belief that can be updated using `updater` that has a similar distribution to `b` (this conversion may be lossy)
@pomdp_func convert_belief{S,A,O}(updater::BeliefUpdater{S,A,O}, belief::Belief{S}, new_belief::Belief{S}=create_belief(updater)) = belief
