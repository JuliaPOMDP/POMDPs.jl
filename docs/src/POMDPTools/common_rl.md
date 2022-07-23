# CommonRLInterface Integration

POMDPTools provides two-way integration with the [CommonRLInterface.jl package](https://github.com/JuliaReinforcementLearning/CommonRLInterface.jl). Using the [`convert` function](https://docs.julialang.org/en/v1/manual/conversion-and-promotion/#Conversion), one can convert an `MDP` or `POMDP` object to a CommonRLInterface environment, or vice-versa.

For example,

```julia
using POMDPs
using POMDPTools
using POMDPModels
using CommonRLInterface

env = convert(AbstractEnv, BabyPOMDP())

r = act!(env, true)
observe(env)
```
converts a Crying Baby POMDP to an RL environment and acts in and observes the environment. This environment (or any other CommonRLInterface environment), can be converted to an `MDP` or `POMDP`:

```julia
using BasicPOMCP

m = convert(POMDP, env)
planner = solve(POMCPSolver(), m)
a = action(planner, initialstate(m))
```

You can also use the constructors listed below to manually convert between the interfaces.

## Environment Wrapper Types

Since the standard reinforcement learning environment interface offers less information about the internal workings of the environment than the POMDPs.jl interface, MDPs and POMDPs created from these environments will have limited functionality. There are two types of (PO)MDP types that can wrap an environment:

### Generative model wrappers

If the `state` and `setstate!` CommonRLInterface functions are provided, then the environment can be wrapped in a [`RLEnvMDP`](@ref) or [`RLEnvPOMDP`](@ref) and the POMDPs.jl generative model interface will be available.

### Opaque wrappers

If the `state` and `setstate!` are not provided, then the resulting `POMDP` or `MDP` can only be simulated. This case is represented using the [`OpaqueRLEnvPOMDP`](@ref) and [`OpaqueRLEnvMDP`](@ref) wrappers. From the POMDPs.jl perspective, the state of the opaque (PO)MDP is just an integer wrapped in an `OpaqueRLEnvState`. This keeps track of the "age" of the environment so that POMDPs.jl actions that attempt to interact with the environment at a different age are invalid.

## Constructors

### Creating RL environments from MDPs and POMDPs

```@docs
MDPCommonRLEnv
POMDPCommonRLEnv
```

### Creating MDPs and POMDPs from RL environments

```@docs
RLEnvMDP
RLEnvPOMDP
OpaqueRLEnvMDP
OpaqueRLEnvPOMDP
```
