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
- `AbstractInterpolants`
- `Solver`
- `Policy`

## Model functions

- `states(pomdp::POMDP)` returns something that might be iterable (e.g., 1:100)
- `actions!(actions::Array, pomdp::POMDP, state)` fills the actions array with valid actions from current state
- `observations(pomdp::POMDP)` returns something that might be iterable (e.g., 1:100)
- `reward(pomdp::POMDP, state, action)` returns reward
- `transition!(distribution, pomdp::POMDP, state, action)` changes the transition distribution to the one availiabe from the current state-action pair 
- `observation!(distribution, pomdp::POMDP, action, state)` changes the observation distribution to the one availiabe from the current state-action pair 
- `create_state(pomdp::POMDP)` returns an initial state
- `create_action(pomdp::POMDP)` returns an initial action

## Solver functions

- `solve(solver::Solver, pomdp::POMDP)` returns a policy
- `solve!(policy, solver::Solver, pomdp::POMDP)` fills the policy

## Distribution Functions

- `rand!(sample, d::AbstractDistribution)` fill with random sample from distribution
- `pdf(d::AbstractDistribution, x)` probaiblity density at x from distribution
- `create_transition(pomdp::POMDP)` returns a transition distribution
- `create_observation(pomdp::POMDP)` returns an observation distribution



