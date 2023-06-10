# Implemented Policies

POMDPTools currently provides the following policy types:
- a wrapper to turn a function into a `Policy`
- an alpha vector policy type
- a random policy
- a stochastic policy type
- exploration policies
- a vector policy type
- a wrapper to collect statistics and errors about policies

In addition, it provides the [`showpolicy`](@ref) function for printing policies similar to the way that matrices are printed in the repl and the [`evaluate`](@ref) function for evaluating MDP policies.

## Function 

Wraps a `Function` mapping states to actions into a `Policy`. 

```@docs
FunctionPolicy
```

```@docs
FunctionSolver
```

## Alpha Vector Policy

Represents a policy with a set of alpha vectors (See `AlphaVectorPolicy` constructor docstring). In addition to finding the optimal action with `action`, the alpha vectors can be accessed with [`alphavectors`](@ref) or [`alphapairs`](@ref).

Determining the estimated value and optimal action depends on calculating the dot product between alpha vectors and a belief vector. [`POMDPTools.Policies.beliefvec(pomdp, b)`](@ref) is used to create this vector and can be overridden for new belief types for efficiency.

```@docs
AlphaVectorPolicy
alphavectors
alphapairs
POMDPTools.Policies.beliefvec
``` 

## Random Policy 

A policy that returns a randomly selected action using `rand(rng, actions(pomdp))`.

```@docs
RandomPolicy
``` 

```@docs
RandomSolver
```

## Stochastic Policies 

Types for representing randomized policies:

- `StochasticPolicy` samples actions from an arbitrary distribution.
- `UniformRandomPolicy` samples actions uniformly (see `RandomPolicy` for a similar use)
- `CategoricalTabularPolicy` samples actions from a categorical distribution with weights given by a `ValuePolicy`.

```@docs
StochasticPolicy
```

```@docs
CategoricalTabularPolicy
```

## Vector Policies

Tabular policies including the following:

- `VectorPolicy` holds a vector of actions, one for each state, ordered according to [`stateindex`](@ref).
-  `ValuePolicy` holds a matrix of values for state-action pairs and chooses the action with the highest value at the given state


```@docs
VectorPolicy 
``` 

```@docs
VectorSolver
```

```@docs
ValuePolicy
```

## Value Dict Policy
`ValueDictPolicy` holds a dictionary of values, where the key is state-action tuple, and chooses the action with the highest value at the given state. It allows one to write solvers without enumerating state and action spaces, but actions and states must support `Base.isequal()` and `Base.hash()`.

```@docs
ValueDictPolicy
```

## Exploration Policies 

Exploration policies are often useful for Reinforcement Learning algorithm to choose an action that is different than the action given by the policy being learned (`on_policy`). 

Exploration policies are subtype of the abstract `ExplorationPolicy` type and they follow the following interface: 
`action(exploration_policy::ExplorationPolicy, on_policy::Policy, k, s)`. `k` is used to compute the value of the exploration parameter (see [Schedule](@ref)), and `s` is the current state or observation in which the agent is taking an action.

The `action` method is exported by [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl). 
To use exploration policies in a solver, you must use the four argument version of `action` where `on_policy` is the policy being learned (e.g. tabular policy or neural network policy).

This package provides two exploration policies: `EpsGreedyPolicy` and `SoftmaxPolicy`

```@docs 
    EpsGreedyPolicy
    SoftmaxPolicy
```

### Schedule

Exploration policies often rely on a key parameter: $\epsilon$ in $\epsilon$-greedy and the temperature in softmax for example. 
Reinforcement learning algorithms often require a decay schedule for these parameters. 
Schedule can be passed to an exploration policy as functions. For example one can define an epsilon greedy policy with an exponential decay schedule as follow: 
```julia 
    m # your mdp or pomdp model
    exploration_policy = EpsGreedyPolicy(m, k->0.05*0.9^(k/10))
```

`POMDPTools` exports a linear decay schedule object that can be used as well.  

```@docs 
    LinearDecaySchedule 
```

## Playback Policy

A policy that replays a fixed sequence of actions. When all actions are used, a backup policy is used.

```@docs
PlaybackPolicy
```

## Utility Wrapper

A wrapper for policies to collect statistics and handle errors.

```@docs
PolicyWrapper
```

## Pretty Printing Policies

```@docs
showpolicy
```

# Policy Evaluation

The [`evaluate`](@ref) function provides a policy evaluation tool for MDPs:

```@docs
evaluate
```
