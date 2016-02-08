"""
Provides a basic interface for working with MDPs/POMDPs
"""
POMDPs

#################################################################
####################### Problem Model ###########################
#################################################################

"""
Base type for a POMDP model, defined by the user
"""
POMDP


"""
Base type for state, action and observation spaces
"""
AbstractSpace


"""
Base type for states
"""
State


"""
Base type for actions
"""
Action


"""
Base type for observation
"""
Observation


"""
    states(pomdp::POMDP)
    
Returns the complete state space of a POMDP. 
"""
states


"""
    actions(pomdp::POMDP)

Returns the entire action space of a POMDP.
"""
actions(pomdp::POMDP)


"""
    actions(pomdp::POMDP, state::State, aspace::AbstractSpace)

Modifies aspace to the action space accessible from the given state and returns it.
"""
actions(pomdp::POMDP, state::State, aspace::AbstractSpace)


"""
    actions(pomdp::POMDP, belief::Belief, aspace::AbstractSpace)

Modifies aspace to the action space accessible from the states with nonzero belief and returns it.
"""
actions(pomdp::POMDP, belief::Belief, aspace::AbstractSpace)


"""
    observations(pomdp::POMDP)

Returns the entire observation space.
"""
observations(pomdp::POMDP)


"""
    observations(pomdp::POMDP, state::State, ospace::AbstractSpace)

Modifies ospace to the observation space accessible from the given state and returns it.
"""
observations(pomdp::POMDP, state::State, ospace::AbstractSpace)


"""
    reward(pomdp::POMDP, state::State, action::Action, statep::State)

Returns the immediate reward for the s-a-s' triple
"""
reward


"""
    transition(pomdp::POMDP, state::State, action::Action)

Returns the transition distribution from the current state-action pair
"""
transition(pomdp::POMDP, state::State, action::Action)

"""
    transition(pomdp::POMDP, state::State, action::Action, distribution::AbstractDistribution)

Modifies distribution to the transition distribution from the current state-action pair and returns it
"""
transition(pomdp::POMDP, state::State, action::Action, distribution::AbstractDistribution)


"""
    observation(pomdp::POMDP, state::State, action::Action, statep::State)

Returns the observation distribution for the s-a-s' tuple (state, action, and next state)
"""
observation(pomdp::POMDP, state::State, action::Action, statep::State)


"""
    observation(pomdp::POMDP, state::State, action::Action, statep::State, distribution::AbstractDistribution)

Modifies distribution to the observation distribution for the s-a-s' tuple (state, action, and next state) and returns it
"""
observation(pomdp::POMDP, state::State, action::Action, statep::State, distribution::AbstractDistribution)


"""
    discount(pomdp::POMDP)

Returns the discount factor
"""
discount


"""
    isterminal(pomdp::POMDP, s::State)

Checks if state s is terminal
"""
isterminal



#################################################################
####################### Distributions ###########################
#################################################################

"""
Base type for a probability distribution
"""
AbstractDistribution

"""
    rand(rng::AbstractRNG, d::AbstractDistribution, sample)

Fill sample with a random element from distribution d. The sample can be a state, action or observation.
"""
rand(rng::AbstractRNG, d::AbstractDistribution, sample)

"""
    rand(rng::AbstractRNG, s::AbstractSpace, sample)

Fill sample with a random element from space s. The sample can be a state, action or observation.
"""
rand(rng::AbstractRNG, s::AbstractSpace, sample)

"""
    pdf(d::AbstractDistribution, x)

Value of probability distribution function at x
"""
pdf




#################################################################
##################### Solvers and Policies ######################
#################################################################

"""
Base type for an MDP/POMDP solver
"""
Solver

"""
Base type for a policy (a map from every possible belief, or more abstract policy state, to an optimal or suboptimal action)
"""
Policy

"""
    solve(solver::Solver, pomdp::POMDP)

Solves the POMDP using method associated with solver, and returns a policy. 
"""
solve(solver::Solver, pomdp::POMDP)

"""
    solve(solver::Solver, pomdp::POMDP, policy::Policy)

Solves the POMDP and modifies policy to be the solution of pomdp and returns it
"""
solve(solver::Solver, pomdp::POMDP, policy::Policy)


"""
    action(policy::Policy, belief::Belief)

Returns an action for the current belief, given the policy

"""
action(policy::Policy, belief::Belief)

"""
    action(policy::Policy, belief::Belief, a::Action)

Fills and returns action a for the current belief, given the policy
"""
action(policy::Policy, belief::Belief, a::Action)

"""
    action(policy::Policy, s::State)

Returns an action for the current state, given the policy

"""
action(policy::Policy, s::State)

"""
    action(policy::Policy, s::State, a::Action)

Fills and returns action a for the current state, given the policy
"""
action(policy::Policy, s::State, a::Action)

"""
    value(policy::Policy, s::State)

Returns the utility value from a given state
"""
value(policy::Policy, s::State)

"""
    value(policy::Policy, b::Belief)

Returns the utility value from a given belief
"""
value(policy::Policy, b::Belief)



#################################################################
############################ Belief #############################
#################################################################

"""
Base type for an object representing some knowledge about the state (often a probability distribution)
"""
Belief

"""
Base type for an object that defines how a belief should be updated
"""
BeliefUpdater

"""
    update(updater::BeliefUpdater, belief_old::Belief, action::Action, obs::Observation)

Returns a new instance of an updated belief given the old belief (belief_old) and the latest action and observation 
"""
update(updater::BeliefUpdater, belief_old::Belief, action::Action, obs::Observation)

"""
    update(updater::BeliefUpdater, belief_old::Belief, action::Action, obs::Observation, belief_new::Belief)

Modifies belief_new to the belief given the old belief (belief_old) and the latest action and observation and returns
the updated belief
"""
update(updater::BeliefUpdater, belief_old::Belief, action::Action, obs::Observation, belief_new::Belief)

"""
    initial_belief(pomdp::POMDP)

Returns an initial belief for the pomdp
"""
initial_belief

"""
    convert_belief(updater::BeliefUpdater, b::Belief)

Returns a belief that can be updated using updater that has a similar distribution to b
"""
convert_belief

"""
    updater(p::Policy)
Returns a default BeliefUpdater appropriate for the passed in policy
"""
updater

#################################################################
############################ Simulation #########################
#################################################################

"""
Base type for an object defining how a simulation should be carried out
"""
Simulator

"""
    simulate(simulator::Simulator, pomdp::POMDP, policy::Policy, updater::BeliefUpdater, initial_belief::Belief)

Runs a simulation using the specified policy and returns the accumulated reward
"""
simulate



#################################################################
######################### Convenience ###########################
#################################################################

"""
    index(pomdp::POMDP, state::State)

Returns the index of the given state for a discrete POMDP
"""
index(pomdp::POMDP, s::State)

"""
    iterator(space::AbstractSpace)

Returns an iterator over a space
"""
iterator(space::AbstractSpace)



#################################################################
############################ Creators ###########################
#################################################################

"""
    create_state(pomdp::POMDP)

Creates a single state object (for preallocation purposes)
"""
create_state(pomdp::POMDP)

"""
    create_observation(pomdp::POMDP)

Creates a single observation object (for preallocation purposes)
"""
create_observation(pomdp::POMDP)

"""
    create_transition_distribution(pomdp::POMDP)

Returns a transition distribution
"""
create_transition_distribution(pomdp::POMDP)

"""
    create_observation_distribution(pomdp::POMDP)

Returns an observation distribution
"""
create_observation_distribution(pomdp::POMDP)

"""
    create_policy(solver::Solver, pomdp::POMDP)

Creates a policy object (for preallocation purposes)
"""
create_policy(solver::Solver, pomdp::POMDP)

"""
    create_action(pomdp::POMDP)

Creates an action object (for preallocation purposes)
"""
create_action(pomdp::POMDP)

"""
    create_belief(pomdp::POMDP)

Creates a belief either to be used by updater or pomdp
"""
create_belief(pomdp::POMDP)
