[![Build Status](https://travis-ci.org/JuliaPOMDP/POMDPs.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/POMDPs.jl)

# POMDPs

This package provides a basic interface for working with partially observable Markov decision processes (POMDPs).

The goal is to provide a common programming vocabulary for researchers and students to use primarily for three tasks:

1. Expressing problems using the POMDP format. 
2. Writing solver software.
3. Running simulations efficiently.


## Installation
```julia
Pkg.clone("https://github.com/JuliaPOMDP/POMDPs.jl.git")
```

## Supported Solvers

The following MDP solvers support this interface:
* [Value Iteration](https://github.com/JuliaPOMDP/DiscreteValueIteration.jl)
* [Monte Carlo Tree Search](https://github.com/JuliaPOMDP/MCTS.jl)

The following POMDP solvers support this interface:
* [QMDP](https://github.com/JuliaPOMDP/QMDP.jl)
* [SARSOP](https://github.com/JuliaPOMDP/SARSOP.jl)
* [POMCP](https://github.com/JuliaPOMDP/POMCP.jl)
* [POMDPSolve](https://github.com/JuliaPOMDP/POMDPSolve.jl)

To install a solver run the following command:
```julia
using POMDPs
# the following command adds the SARSOP solver, you can add any supported solver this way
POMDPs.add("SARSOP") 
```


## Tutorials

The following tutorials aim to get you up to speed with POMDPs.jl:
* [MDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/GridWorld.ipynb) for beginners
  gives an overview of using Value Iteration and Monte-Carlo Tree Search with the classic grid world problem
* [POMDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/Tiger.ipynb) gives an overview
  of using SARSOP and QMDP to solve the tiger problem


## Core Interface

The core interface provides tools to express problems, program solvers, and setup simulations.

**TODO** this list is not complete! there are some functions in src missing documentation that were not included here


### Distributions

`AbstractDistribution` - Base type for a probability distribution

- `rand(rng::AbstractRNG, d::AbstractDistribution, sample::Any)` fill with random sample from distribution and return the sample
- `pdf(d::AbstractDistribution, x)` value of probability distribution function at x

**XXX** There are functions missing from this list that are included in `src/distribution.jl`

### Problem Model

`POMDP` - Base type for a problem definition<br>
`AbstractSpace` - Base type for state, action, and observation spaces<br>
`State` - Base type for states<br>
`Action` - Base type for actions<br>
`Observation` - Base type for observations

- `states(pomdp::POMDP)` returns the complete state space
- `states(pomdp::POMDP, state::State, sts::AbstractSpace=states(pomdp))` modifies `sts` to the state space accessible from the given state and returns it 
- `actions(pomdp::POMDP)` returns the complete action space
- `actions(pomdp::POMDP, state::State, aspace::AbstractSpace=actions(pomdp))` modifies `aspace` to the action space accessible from the given state and returns it
- `actions(pomdp::POMDP, belief::Belief, aspace::AbstractSpace=actions(pomdp))` modifies `aspace` to the action space accessible from the states with nonzero belief and returns it
- `observations(pomdp::POMDP)` returns the complete observation space
- `observations(pomdp::POMDP, state::State, ospace::AbstractSpace)` modifies `ospace` to the observation space accessible from the given state and returns it
- `reward(pomdp::POMDP, state::State, action::Action, statep::State)` returns the immediate reward for the s-a-s' triple
- `transition(pomdp::POMDP, state::State, action::Action, distribution=create_transition_distribution(pomdp))` modifies `distribution` to the transition distribution from the current state-action pair and returns it
- `observation(pomdp::POMDP, state::State, action::Action, statep::State, distribution=create_observation_distribution(pomdp))` modifies `distribution` to the observation distribution for the s-a-s' tuple (state, action, and next state) and returns it
- `observation(pomdp::POMDP, state::State, action::Action, distribution=create_observation_distribution(pomdp))` modifies `distribution` to the observation distribution for the s-a pair (state and action) and returns it
- `discount(pomdp::POMDP)` returns the discount factor
- `isterminal(pomdp::POMDP, state::State)` checks if a state is terminal
- `isterminal(pomdp::POMDP, observation::Observation)` checks if an observation is terminal. A terminal observation should be generated only upon transition to a terminal state.

**XXX** Missing functions such as `n_states`, `n_actions` (see `src/pomdp.jl`)

### Solvers and Polices

`Solver` - Base type a solver<br>
`Policy` - Base type for a policy (a map from every possible belief, or more abstract policy state, to an optimal or suboptimal action)

- `solve(solver::Solver, pomdp::POMDP, policy::Policy=create_policy(solver, pomdp))` solves the POMDP and modifies `policy` to be the solution of `pomdp` and returns it
- `action(policy::Policy, belief::Belief)` or `action(policy::Policy, belief::Belief, act::Action)` returns an action for the current belief given the policy (the method with three arguments modifies `act` and returns it)
- `action(policy::Policy, state::State)` or `action(policy::Policy, state::State, act::Action)` returns an action for the current state given the policy

### Belief

`Belief` - Base type for an object representing some knowledge about the state (often a probability distribution)<br>
`BeliefUpdater` - Base type for an object that defines how a belief should be updated

- `update(updater::BeliefUpdater, belief_old::Belief, action::Action, obs::Observation, belief_new::Belief=create_belief(updater))` modifies `belief_new` to the belief given the old belief (`belief_old`) and the latest action and observation and returns the updated belief. 

### Simulation

`Simulator` - Base type for an object defining how a simulation should be carried out

- `simulate(simulator::Simulator, pomdp::POMDP, policy::Policy, updater::BeliefUpdater, initial_belief::Belief)` runs a simulation using the specified policy and returns the accumulated reward

## Minor Components

### Convenience Functions

Several convenience functions are also provided in the interface to provide standard vocabulary for common tasks and may be used by some solvers or in simulation, but they are not strictly necessary for expressing problems.

- `index(pomdp::POMDP, state::State)` returns the index of the given state for a discrete POMDP 
- `initial_belief(pomdp::POMDP)` returns an example initial belief for the pomdp
- `iterator(space::AbstractSpace)` returns an iterator over a space or an iterable object containing the space (such as an array)
- `dimensions(s::AbstractSpace)` returns the number (integer) of dimensions in a space
- `lowerbound(s::AbstractSpace, i::Int)` returns the lower bound of dimension `i`
- `upperbound(s::AbstractSpace, i::Int)` returns the upper bound of dimension `i`
- `rand(rng::AbstractRNG, d::AbstractSpace, sample::Any)` fill with random sample from space and return the sample
- `value(policy::Policy, belief::Belief)` returns the utility value from policy p given the belief
- `value(policy::Policy, state::State)` returns the utility value from policy p given the state
- `convert_belief(updater::BeliefUpdater, b::Belief)` returns a belief that can be updated using `updater` that has a similar distribution to `b` (this conversion may be lossy)
- `updater(p::Policy)` returns a default BeliefUpdater appropriate for a belief type that policy `p` can use

### Object Creators

In many cases, it is more efficient to fill pre-allocated objects with new data rather than create new objects at each iteration of an algorithm or simulation. When a new object is needed, the following functions may be called. They should return an object of the appropriate type as efficiently as possible. The data in the object does not matter - it will be overwritten when the object is used.

- `create_state(pomdp::POMDP)` creates a single state object (for preallocation purposes)
- `create_observation(pomdp::POMDP)` creates a single observation object (for preallocation purposes)
- `create_transition_distribution(pomdp::POMDP)` returns a transition distribution
- `create_observation_distribution(pomdp::POMDP)` returns an observation distribution
- `create_policy(solver::Solver, pomdp::POMDP)` creates a policy object (for preallocation purposes)
- `create_action(pomdp::POMDP)` creates an action object (for preallocation purposes)
- `create_belief(updater::BeliefUpdater)` creates a belief object of the type used by `updater` (for preallocation purposes)
- `create_belief(pomdp::POMDP)` creates an empty problem-native belief object (for preallocation purposes)


## Reference Simulation Implementation

This reference simulation implementation shows how the various functions will be used. Please note that this example is written for clarity and not efficiency (see [TODO: link to main doc] for efficiency tips).

```julia
type ReferenceSimulator
    rng::AbstractRNG
    max_steps
end

function simulate(simulator::ReferenceSimulator, pomdp::POMDP, policy::Policy, updater::BeliefUpdater, initial_belief::Belief)

    s = create_state(pomdp)
    o = create_observation(pomdp)
    rand(sim.rng, initial_belief, s)
    
    b = convert_belief(updater, initial_belief)

    step = 1
    disc = 1.0
    r = 0.0

    while step <= sim.max_steps && !isterminal(pomdp, s)
        a = action(policy, b)

        sp = create_state(pomdp)
        trans_dist = transition(pomdp, s, a)
        rand(sim.rng, trans_dist, sp)

        r += disc*reward(pomdp, s, a, sp)

        obs_dist = observation(pomdp, s, a, sp)
        rand(sim.rng, obs_dist, o)

        b = update(updater, b, a, o)

        s = sp
        disc *= discount(pomdp)
        step += 1
    end

end

```
