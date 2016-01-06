"""
Provides a basic interface for working with MDPs/POMDPs
"""
POMDPs

#################################################################
####################### Problem Model ###########################
#################################################################

"""
Base type for a problem definition, defined by the user
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
Returns the complete state space. 
"""
states


"""
Returns an action space. There are three methods for actions:

    returns the entire action space:
    actions(pomdp::POMDP)

    modifies aspace to the action space accessible from the given state and returns it:
    actions(pomdp::POMDP, state::State, aspace::AbstractSpace)

    modifies aspace to the action space accessible from the states with nonzero belief and returns it:
    actions(pomdp::POMDP, belief::Belief, aspace::AbstractSpace)
"""
actions


"""
Returns an observation space. There are two methods for observations:

    returns the entire observation space:
    observations(pomdp::POMDP)

    modifies ospace to the observation space accessible from the given state and returns it:
    observations(pomdp::POMDP, state::State, ospace::AbstractSpace)

"""
observations


"""
Returns the immediate reward for the s-a-s' triple
"""
reward


"""
Modifies distribution to the transition distribution from the current state-action pair and returns it
"""
transition


"""
modifies distribution to the observation distribution for the s-a-s' tuple (state, action, and next state) and returns it
"""
observation


"""
returns the discount factor
"""
discount


"""
checks is a state is terminal
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
Fill with random sample from distribution, or space. The sample can be a state, action or observation.
"""
rand!

"""
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
solves the POMDP and modifies policy to be the solution of pomdp and returns it
"""
solve

"""
Returns an action for a given polciy. For a POMDP policy it returns an action for the current belief. The method has the forms:

    action(policy::Policy, belief::Belief)
    action(policy::Policy, belief::Belief, act::Action)

For an MDP policy it return an action for the current state:

    action(policy::Policy, state::State)
    action(policy::Policy, state::State, act::Action)
"""
action

"""
returns the utility value from a given state or belief
"""
value



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
modifies belief_new to the belief given the old belief (belief_old) and the latest action and observation and returns
the updated belief
"""
update

"""
an example initial belief for the pomdp
"""
initial_belief

"""
returns a belief that can be updated using updater that has a similar distribution to b
"""
convert_belief

"""
returns a default BeliefUpdater appropriate for the passed in policy
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
runs a simulation using the specified policy and returns the accumulated reward
"""
simulate



#################################################################
######################### Convenience ###########################
#################################################################

"""
returns the index of the given state for a discrete POMDP
"""
index

"""
returns an iterator over a space
"""
domain



#################################################################
############################ Creators ###########################
#################################################################

"""
creates a single state object (for preallocation purposes)
"""
create_state

"""
creates a single observation object (for preallocation purposes)
"""
create_observation

"""
returns a transition distribution
"""
create_transition_distribution

"""
returns an observation distribution
"""
create_observation_distribution

"""
creates a policy object (for preallocation purposes)
"""
create_policy

"""
creates an action object (for preallocation purposes)
"""
create_action

"""
creates a belief either to be used by updater or pomdp
"""
create_belief
