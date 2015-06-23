# POMDPs

This package provides a basic interface for working with partially observable Markov decision processes (POMDPs).

Installation:
```julia
Pkg.clone("git@bitbucket.org:sisl/POMDPs.jl.git")
```

## Basic Types

The basic types are

- `POMDP`
- `Solver`
- `Simulator`
- `Policy`
- `POMDPFile`
- `PolicyFile`

## Basic functions

- `solve(solver::Solver, pomdp::POMDP)`
- `simulate(simulator::Simulator, pomdp::POMDP, π::Policy)`

## File IO

- `load(file::PolicyFile)`
- `load(file::POMDPFile)`
- `save(file::PolicyFile, policy::Policy)`
- `save(file::POMDPFile, pomdp::POMDP)`

## Model functions

- `states(pomdp::POMDP)` returns something that might be iterable (e.g., 1:100)
- `actions(pomdp::POMDP)` returns something that might be iterable (e.g., 1:100)
- `actions(pomdp::POMDP, state)` returns something that might be iterable (e.g., 1:100)
- `reward(pomdp::POMDP, state, action)` returns reward
- `transition(pomdp::POMDP, state, action, nextState)` returns probability
- `observation(pomdp::POMDP, action, state, observation)` returns probability
- `nextStateDistribution(pomdp::POMDP, state, action)` returns something that might be iterable (e.g., [(10,0.1), (1, 0.8), (15, 0.1)])

## Sampling functions

- `sampleInitial!(pomdp::POMDP, state, observation)` returns nothing
- `sampleNext!(pomdp::POMDP, state, action, observation)` returns reward
- `samplePolicy!(pomdp::POMDP, state, action)` returns action