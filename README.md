# POMDPs

This package provides a basic interface for working with partially observable Markov decision processes (POMDPs).

Installation:
```julia
Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
```

## Supported Solvers

**TODO**: Update these solvers after ! interface change

The following MDP solvers support this interface:
* [Value Iteration](https://github.com/sisl/DiscreteValueIteration.jl)
* [Monte Carlo Tree Search](https://github.com/sisl/MCTS.jl)

The following POMDP solvers support this interface:
* [QMDP](https://github.com/sisl/QMDP.jl)
* [SARSOP](https://github.com/sisl/SARSOP.jl)

## Basic Types

The basic types are

- `POMDP`
- `AbstractDistribution`
- `AbstractSpace`
- `Belief`
- `Solver`
- `Policy`

## Model functions

- `discount(pomdp::POMDP)` returns the discount
- `states(pomdp::POMDP)` returns the complete state space 
- `actions(pomdp::POMDP)` returns the complete action space
- `actions(pomdp::POMDP, state::Any, aspace::AbstractSpace=actions(pomdp))` modifies `aspace` to the action space accessible from the given state and returns it
- `observations(pomdp::POMDP)` returns the complete observation space
- `observations(pomdp::POMDP, state::Any, ospace::AbstractSpace)` modifies `ospace` to the observation space accessible from the given state and returns it
- `reward(pomdp::POMDP, state::Any, action::Any)` returns the immediate reward for the state-action pair
- `reward(pomdp::POMDP, state::Any, action::Any, statep::Any)` returns the immediate reward for the s-a-s' triple
- `transition(pomdp::POMDP, state, action, distribution=create_transition_distribution(pomdp))` modifies `distribution` to the transition distribution from the current state-action pair and returns it
- `observation(pomdp::POMDP, state, action, distribution=create_transition_distribution(pomdp))` modifies `distribution` to the observation distribution from the current state and *previous* action and returns it
- `isterminal(pomdp::POMDP, state::Any)` checks if a state is terminal
- `create_state(pomdp::POMDP)` creates a single state object (for preallocation purposes)
- `create_observation(pomdp::POMDP)` creates a single observation object (for preallocation purposes)
- `index(pomdp::POMDP, state::State)` returns the index of the given state for a discrete POMDP 


## Distribution Functions

- `rand!(rng::AbstractRNG, sample, d::AbstractDistribution)` fill with random sample from distribution
- `pdf(d::AbstractDistribution, x)` value of probability distribution function at x
- `create_transition_distribution(pomdp::POMDP)` returns a transition distribution
- `create_observation_distribution(pomdp::POMDP)` returns an observation distribution


## Space Functions
- `domain(space::AbstractSpace)` returns an iterator over a space


## Solver functions

- `solve(solver::Solver, pomdp::POMDP)` returns a policy


## Policy Functions
- `action(policy::Policy, belief::Belief)` returns an action for the current belief given the policy
- `action(policy::Policy, state::Any)` returns an action for the current state given the policy
- `value(policy::Policy, belief::Belief)` returns the expected value for the current belief given the policy
- `value(policy::Policy, state::Any)` returns the expected value for the current state given the policy


## Belief Functions
- `create_belief(pomdp::POMDP)` creates a belief object (for preallocation purposes)
- `belief(pomdp::POMDP, bold::Belief, action::Any, obs::Any, distribution::Belief=create_belief(pomdp))` modifies `distribution` to the belief given the old belief and the latest action and observation and returns the updated belief. `bold` and `distribution` should *not* be references to the same object

## Simulation Functions
- `simulate(pomdp::POMDP, policy::Policy,initial_belief::Belief,rng=MersenneTwister(),eps=0.0,initial_state=nothing)` 
runs a simulation using the specified policy and returns the accumulated reward
- `simulate(mdp::POMDP, policy::Policy,initial_state::Any,rng=MersenneTwister(),eps=0.0)` runs a simulation using the
specified policy and returns the accumulated reward


