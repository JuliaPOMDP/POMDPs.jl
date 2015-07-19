# POMDPs

This package provides a basic interface for working with partially observable Markov decision processes (POMDPs).

Installation:
```julia
Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
```

## Basic Types

The basic types are

- `POMDP`
- `DsicretePOMDP`
- `AbstractDistribution`
- `AbstractSpace`
- `Solver`
- `Policy`

## Model functions

- `states(pomdp::POMDP)` returns the complete state space 
- `actions(pomdp::POMDP)` returns the complete action space
- `actions!(aspace::AbstractSpace, pomdp::POMDP, state::Any)` changes aspace to the action space accessible from the given state
- `observations(pomdp::POMDP)` returns the complete observation space
- `observations!(ospace::AbstractSpace, pomdp::POMDP, state::Any)` changes ospace to the obsevation space accessible from the given state
- `reward(pomdp::POMDP, state::Any, action::Any)` returns the immidiate reward for the state-action pair
- `transition!(distribution, pomdp::POMDP, state, action)` changes the transition distribution to the one availiabe from the current state-action pair 
- `observation!(distribution, pomdp::POMDP, action, state)` changes the observation distribution to the one availiabe from the current state-action pair 


## Distribution Functions

- `rand!(sample, d::AbstractDistribution)` fill with random sample from distribution
- `pdf(d::AbstractDistribution, x)` value of probablity distribution function at x
- `create_transition(pomdp::POMDP)` returns a transition distribution
- `create_observation(pomdp::POMDP)` returns an observation distribution


## Space Functions
- `domain(space::AbstractSpace)` returns an iterator over a space


## Solver functions

- `solve(solver::Solver, pomdp::POMDP)` returns a policy
- `solve!(policy, solver::Solver, pomdp::POMDP)` fills the policy


## Policy Functions
- `get_action(policy::Policy, belief::Belief)` returns an action for the current belief given the policy
- `get_action(policy::Policy, state::Any)` returns an action for the current state given the policy
- `get_value(policy::Policy, belief::Belief)` returns the expected value for the current belief given the policy
- `get_value(policy::Policy, state::Any)` returns the expected value for the current state given the policy

