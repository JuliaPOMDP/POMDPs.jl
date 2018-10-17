# Simulation Standard

Important note: In most cases, **users need not implement their own simulators**. Several simulators that are compatible with the standard in this document are implemented in the [POMDPSimulators package](https://github.com/JuliaPOMDP/POMDPSimulators.jl) and allow [interaction from a variety of perspectives](https://juliapomdp.github.io/POMDPSimulators.jl/latest/which.html#Which-Simulator-Should-I-Use?-1). Moreover [DeepRL.jl](https://github.com/sisl/DeepRL.jl) provides an OpenAI Gym style environment interface to interact with environments that is more flexible in some cases.

In order to maintain consistency across the POMDPs.jl ecosystem, this page defines a standard for how simulations should be conducted. All simulators should be consistent with this page, and, if solvers are attempting to find an optimal POMDP policy, they should optimize the expected value of `r_total` below. In particular, this page should be consulted when questions about how less-obvious concepts like terminal states are handled.

## POMDP Simulation

### Inputs

In general, POMDP simulations take up to 5 inputs (see the [`simulate`](@ref) function for documentation on arguments):

- `pomdp::POMDP`: pomdp model object (see [POMDPs and MDPs](@ref))
- `policy::Policy`: policy (see [Solvers and Policies](@ref))
- `up::Updater`: belief updater (see [Beliefs and Updaters](@ref))
- `isd`: initial state distribution
- `s`: initial state

The last three of these inputs are optional. If they are not explicitly provided, they should be inferred using the following POMDPs.jl functions:

- `up = `[`updater`](@ref)`(policy)`
- `isd = `[`initialstate_distribution`](@ref)`(pomdp)`
- `s = `[`initialstate`](@ref)`(pomdp, rng)`

In addition, a random number generator `rng` is assumed to be available.

### Simulation Loop

The main simulation loop is shown below. Note that the [`isterminal`](@ref) check prevents any actions from being taken and reward from being collected from a terminal state.

Before the loop begins, [`initialize_belief`](@ref) is called to create the [belief](@ref beliefs_and_updaters) based on the initial state distribution - this is especially important when the belief is solver specific, such as the finite-state-machine used by MCVI. 

```julia
b = initialize_belief(up, isd)

r_total = 0.0
d = 1.0
while !isterminal(pomdp, s)
    a = action(policy, b)
    s, o, r = generate_sor(pomdp, s, a, rng)
    r_total += d*r
    d *= discount(pomdp)
    b = update(up, b, a, o)
end
```

In terms of the explicit interface, [`generate_sor`](@ref) above can be expressed as:

```julia
function generate_sor(pomdp, s, a, rng)
    sp = rand(rng, transition(pomdp, s, a))
    o = rand(rng, observation(pomdp, s, a, sp))
    r = reward(pomdp, s, a, sp)
    return sp, o, r
end
```

## MDP Simulation

### Inputs

In general, MDP simulations take up to 3 inputs (see the [`simulate`](@ref) function for documentation on arguments):

- `mdp::MDP`: mdp model object (see [POMDPs and MDPs](@ref))
- `policy::Policy`: policy (see [Solvers and Policies](@ref))
- `s`: initial state

The last of these inputs is optional. If the initial state is not explicitly provided, it should be generated using

- `s = `[`initialstate`](@ref)`(mdp, rng)`

In addition, a random number generator `rng` is assumed to be available.

### Simulation Loop

The main simulation loop is shown below. Note again that the [`isterminal`](@ref) check prevents any actions from being taken and reward from being collected from a terminal state.

```julia
r_total = 0.0
disc = 1.0
while !isterminal(mdp, s)
    a = action(policy, b)
    s, r = generate_sr(mdp, s, a, rng)
    r_total += d*r
    d *= discount(mdp)
end
```

In terms of the explicit interface, [`generate_sr`](@ref) above can be expressed as:

```julia
function generate_sr(mdp, s, a, rng)
    sp = rand(rng, transition(pomdp, s, a))
    r = reward(pomdp, s, a, sp)
    return sp, r
end
```
