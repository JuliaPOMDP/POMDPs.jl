# API Documentation

Docstrings for POMDPs.jl interface members can be [accessed through Julia's built-in documentation system](https://docs.julialang.org/en/v1/manual/documentation/index.html#Accessing-Documentation-1) or in the list below.

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

### Dynamics

```@docs
transition
observation
reward
gen
@gen
```

### Static Properties

```@docs
states
actions
observations
isterminal
discount
initialstate
initialobs
stateindex
actionindex
obsindex
convert_s
convert_a
convert_o
```

### Distributions and Spaces

```@docs
rand
pdf
mode
mean
support
```

## Belief Functions

```@docs
update
initialize_belief
history
currentobs
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

### Utility Tools

```@docs
add_registry
```
