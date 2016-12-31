# API Documentation

Documentation for the `POMDPs.jl` user interface. You can get help for any type or
function in the module by typing `?` in the Julia REPL followed by the name of
type or function. For example:

```julia
julia> using POMDPs
julia> ?
help?> reward
search: reward

  reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A, statep::S)

  Returns the immediate reward for the s-a-s triple

  reward{S,A,O}(pomdp::POMDP{S,A,O}, state::S, action::A)

  Returns the immediate reward for the s-a pair

```

```@meta
CurrentModule = POMDPs
```

## Contents

```@contents
Pages = ["api.md"]
```


## Index

```@index
Pages = ["api.md"]
```


## Types

```@docs
POMDP
MDP
Solver
Policy
Updater
```


## Model Functions

```@docs
states
actions
observations
reward
transition
observation
isterminal
isterminal_obs
discount
n_states
n_actions
n_observations
state_index
action_index
obs_index
```

## Distribution/Space Functions

```@docs
rand
pdf
dimensions
iterator
initial_state_distribution
```

## Belief Functions

```@docs
update
initialize_belief
```

## Policy and Solver Functions

```@docs
solve
updater
action
value
```

## Simulator

```@docs
Simulator
simulate
```

## Other

The following functions are not part of the API for specifying and solving POMDPs, but are included in the package.

### Type Inference

```@docs
state_type
action_type
obs_type
```

### Requirements Specification
```@docs
check_requirements
show_requirements
get_requirements
requirements_info
@POMDP_require
@POMDP_requirements
@requirements_info
@get_requirements
@show_requirements
@warn_requirements
@req
@subreq
implemented
```

### Utility Tools

```@docs
add
add_all
test_all
available
```
