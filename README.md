# POMDPs

This package provides a basic interface for working with partially observable Markov decision processes (POMDPs).

Installation:
```julia
Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
```

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
- `actions!(aspace::AbstractSpace, pomdp::POMDP, state::Any)` changes aspace to the action space accessible from the given state
- `observations(pomdp::POMDP)` returns the complete observation space
- `observations!(ospace::AbstractSpace, pomdp::POMDP, state::Any)` changes ospace to the obsevation space accessible from the given state
- `reward(pomdp::POMDP, state::Any, action::Any)` returns the immidiate reward for the state-action pair
- `reward(pomdp::POMDP, state::Any, action::Any, statep::Any)` returns the immidiate reward for the s-a-s' triple
- `transition!(distribution, pomdp::POMDP, state, action)` changes the transition distribution to the one availiabe from the current state-action pair 
- `observation!(distribution, pomdp::POMDP, state, action)` changes the observation distribution to the one availiabe from the current state and previous action 
- `isterminal(pomdp::POMDP, state::Any)` checks if a state is terminal
- `create_state(pomdp::POMDP)` creates a single state object (for preallocation purposes)
- `create_observation(pomdp::POMDP)` creates a single observation object (for preallocation purposes)


## Distribution Functions

- `rand!(rng::AbstractRNG, sample, d::AbstractDistribution)` fill with random sample from distribution
- `pdf(d::AbstractDistribution, x)` value of probablity distribution function at x
- `create_transition_distribution(pomdp::POMDP)` returns a transition distribution
- `create_observation_distribution(pomdp::POMDP)` returns an observation distribution


## Space Functions
- `domain(space::AbstractSpace)` returns an iterator over a space


## Solver functions

- `solve(solver::Solver, pomdp::POMDP)` returns a policy
- `solve!(policy, solver::Solver, pomdp::POMDP)` fills the policy


## Policy Functions
- `action(policy::Policy, belief::Belief)` returns an action for the current belief given the policy
- `action(policy::Policy, state::Any)` returns an action for the current state given the policy
- `value(policy::Policy, belief::Belief)` returns the expected value for the current belief given the policy
- `value(policy::Policy, state::Any)` returns the expected value for the current state given the policy


## Belief Functions
- `update_belief!(b::Belief, pomdp::POMDP, action::Any, obs::Any)` updates the belief b given the previous belief, the
  action and the observation
