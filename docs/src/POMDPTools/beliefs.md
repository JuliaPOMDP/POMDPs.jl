# Implemented Belief Updaters

POMDPTools provides the following generic belief updaters:
- a discrete belief updater
- a k previous observation updater
- a previous observation updater 
- a nothing updater (for when the policy does not depend on any feedback)

For particle filters see [ParticleFilters.jl](https://github.com/JuliaPOMDP/ParticleFilters.jl).

## Discrete (Bayesian Filter)

The `DiscreteUpater` is a default implementation of a discrete Bayesian filter. The `DiscreteBelief` type is provided to represent discrete beliefs for discrete state POMDPs. 

A convenience function `uniform_belief` is provided to create a `DiscreteBelief` with equal probability for each state. 

```@docs 
DiscreteBelief
```

```@docs
DiscreteUpdater
```

```@docs
uniform_belief(pomdp)
```

## K Previous Observations

```@docs
KMarkovUpdater
```

## Previous Observation 

```@docs
PreviousObservationUpdater
```

## Nothing Updater

```@docs
NothingUpdater
```
