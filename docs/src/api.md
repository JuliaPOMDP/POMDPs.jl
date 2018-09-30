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

### [Explicit](@id explicit_api)

These functions return *distributions*.

```@docs
transition
observation
initialstate_distribution
```

### [Generative](@id generative_api)

These functions should return *states*, *observations*, and *rewards*.

```@docs
generate_s
generate_o
generate_sr
generate_so
generate_or
generate_sor
initialstate
```

### [Common](@id common_api)

```@docs
states
actions
observations
reward
isterminal
discount
n_states
n_actions
n_observations
stateindex
actionindex
obsindex
convert_s
convert_a
convert_o
```

## Distribution/Space Functions

```@docs
rand
pdf
mode
mean
dimensions
support
sampletype
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
statetype
actiontype
obstype
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
add_registry
available
```
