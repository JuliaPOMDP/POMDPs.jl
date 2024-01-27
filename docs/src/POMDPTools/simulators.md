# Implemented Simulators 

POMDPTools contains a collection of POMDPs.jl simulators.

Usage examples can be found in the [Simulations Examples](@ref) section.

If you are just getting started, probably the easiest way to begin is the [`stepthrough` function](@ref Stepping-through). Otherwise, consult the [Which Simulator Should I Use?](@ref which_simulator) guide below:

## [Which Simulator Should I Use?](@id which_simulator)

The simulators in this package provide interaction with simulations of MDP and POMDP environments from a variety of perspectives. Use these questions to choose the best simulator to suit your needs.

### I want to run fast rollout simulations and get the discounted reward.

Use the [Rollout Simulator](@ref Rollouts).

### I want to evaluate performance with many parallel Monte Carlo simulations.

Use the [Parallel Simulator](@ref Parallel).

### I want to closely examine the histories of states, actions, etc. produced by simulations.

Use the [History Recorder](@ref History-Recorder).

### I want to step through each individual step of a simulation.

Use the [`stepthrough` function](@ref Stepping-through).

### I want to visualize a simulation.

Use the [`DisplaySimulator`](@ref Display).

Also see the [POMDPGifs package](https://github.com/JuliaPOMDP/POMDPGifs.jl) for creating gif animations.

### I want to interact with a MDP or POMDP environment from the policy's perspective

Use the [`sim` function](@ref sim-function).

## Stepping through

The [`stepthrough`](@ref) function exposes a simulation as an iterator so that the steps can be iterated through with a for loop syntax as follows:

```julia
pomdp = BabyPOMDP()
policy = RandomPolicy(pomdp)

for (s, a, o, r) in stepthrough(pomdp, policy, "s,a,o,r", max_steps=10)
    println("in state $s")
    println("took action $a")
    println("received observation $o and reward $r")
end
```

```@docs
stepthrough
```

The `StepSimulator` contained in this file can provide the same functionality with the following syntax:
```julia
sim = StepSimulator("s,a,r,sp")
for (s,a,r,sp) in simulate(sim, problem, policy)
    # do something
end
```

## Rollouts

`RolloutSimulator` is the simplest MDP or POMDP simulator. When `simulate` is called, it simply simulates a single trajectory of the process and returns the discounted reward.

```julia
rs = RolloutSimulator()
mdp = GridWorld()
policy = RandomPolicy(mdp)

r = simulate(rs, mdp, policy)
```

```@docs
RolloutSimulator
```

## History Recorder

A `HistoryRecorder` runs a simulation and records the trajectory. It returns an `AbstractVector` of `NamedTuples` - see [Histories](@ref) for more info.

```julia
hr = HistoryRecorder(max_steps=100)
pomdp = TigerPOMDP()
policy = RandomPolicy(pomdp)

h = simulate(hr, pomdp, policy)
```

```@docs
HistoryRecorder
```

## [`sim()`](@id sim-function)

The `sim` function provides a convenient way to interact with a POMDP or MDP environment and return a [history](@ref Histories). The first argument is a function that is called at every time step and takes a state (in the case of an MDP) or an observation (in the case of a POMDP) as the argument and then returns an action. The second argument is a pomdp or mdp. It is intended to be used with Julia's [`do` syntax](https://docs.julialang.org/en/v1/manual/functions/#Do-Block-Syntax-for-Function-Arguments-1) as follows:

```julia
pomdp = TigerPOMDP()
history = sim(pomdp, max_steps=10) do obs
    println("Observation was $obs.")
    return TIGER_OPEN_LEFT
end
```
This allows a flexible and general way to interact with a POMDP environment without creating new `Policy` types.

In the POMDP case, an updater can optionally be supplied as an additional positional argument if the policy function works with beliefs rather than directly with observations.

```@docs
sim
```

## Histories

The results produced by [`HistoryRecorder`](@ref)s and the [`sim`](@ref) function are contained in `SimHistory` objects.

```@docs
SimHistory
```

### Examples

```jldoctest histaccess; output = false
using POMDPs, POMDPTools, POMDPModels
hr = HistoryRecorder(max_steps=10)
hist = simulate(hr, BabyPOMDP(), FunctionPolicy(x->true))
step = hist[1] # all information available about the first step
step[:s] # the first state
step[:a] # the first action

# output

true
```

To see everything available in a step, use
```julia
keys(first(hist))
```

The entire history of each variable is available by using a `Symbol` instead of an index, i.e.
```julia
hist[:s]
```
will return a vector of the starting states for each step (note the difference between `:s` and `:sp`).

### `eachstep`

The [`eachstep`](@ref) function may also be useful:

```@docs
eachstep
```

#### Examples:
```julia
collect(eachstep(h, "a,o"))
```
will produce a vector of action-observation named tuples.

```julia
collect(norm(sp-s) for (s,sp) in eachstep(h, "s,sp"))
```
will produce a vector of the distances traveled on each step (assuming the state is a Euclidean vector).

#### Notes
- The iteration specification can be specified as a tuple of symbols (e.g. `(:s, :a)`) instead of a string.
- For type stability in performance-critical code, one should construct an iterator directly using `HistoryIterator{typeof(h), (:a,:r)}(h)` rather than `eachstep(h, "ar")`.

### Other Functions

`state_hist(h)`, `action_hist(h)`, `observation_hist(h)` `belief_hist(h)`, and `reward_hist(h)` will return vectors of the states, actions, and rewards, and `undiscounted_reward(h)` and `discounted_reward(h)` will return the total rewards collected over the trajectory. `n_steps(h)` returns the number of steps in the history. `exception(h)` and `backtrace(h)` can be used to hold an exception if the simulation failed to finish.

`view(h, range)` (e.g. `view(h, 1:n_steps(h)-4)`) can be used to create a view of the history object `h` that only contains a certain range of steps. The object returned by `view` is an `AbstractSimHistory` that can be iterated through and manipulated just like a complete `SimHistory`.

## Parallel

POMDPTools contains a utility for running many Monte Carlo simulations in parallel to evaluate performance. The basic workflow involves the following steps:

1. Create a vector of [`Sim`](@ref) objects, each specifying how a single simulation should be run.
2. Use the [`run_parallel`](@ref) or [`run`](@ref) function to run the simulations.
3. Analyze the results of the simulations contained in the [`DataFrame`](https://github.com/JuliaData/DataFrames.jl) returned by [`run_parallel`](@ref).

### Example

An example can be found in the [Parallel Simulations](@ref) section.

### Sim objects

Each simulation should be specified by a [`Sim`](@ref) object which contains all the information needed to run a simulation, including the `Simulator`, `POMDP` or `MDP`, `Policy`, `Updater`, and any other ingredients.

```@docs
Sim
```

### Running simulations

The simulations are actually carried out by the `run` and `run_parallel` functions.

```@docs
run_parallel
```

The `run` function is also provided to run simulations in serial (this is often useful for debugging). Note that the documentation below also contains a section for the builtin julia `run` function, even though it is not relevant here.

```@docs
run
```

### Specifying information to be recorded

By default, only the discounted rewards from each simulation are recorded, but arbitrary information can be recorded.

The [`run_parallel`](@ref) and [`run`](@ref) functions accept a function (normally specified via the [`do` syntax](https://docs.julialang.org/en/v1/manual/functions/#Do-Block-Syntax-for-Function-Arguments-1)) that takes the [`Sim`](@ref) object and [history](@ref Histories) of the simulation and extracts relevant statistics as a named tuple. For example, if the desired characteristics are the number of steps in the simulation and the reward, [`run_parallel`](@ref) would be invoked as follows:
```julia
df = run_parallel(queue) do sim::Sim, hist::SimHistory
    return (n_steps=n_steps(hist), reward=discounted_reward(hist))
end
```
These statistics are combined into a [`DataFrame`](https://github.com/JuliaData/DataFrames.jl), with each line representing a single simulation, allowing for statistical analysis. For example,
```julia
mean(df[:reward]./df[:n_steps])
```
would compute the average reward per step with each simulation weighted equally regardless of length.

## Display

### `DisplaySimulator`

The `DisplaySimulator` displays each step of a simulation in real time through a multimedia display such as a Jupyter notebook or [ElectronDisplay](https://github.com/queryverse/ElectronDisplay.jl).
Specifically it uses [`POMDPTools.render`](@ref) and the built-in Julia [`display` function](https://docs.julialang.org/en/v1/base/io-network/#Base.Multimedia.display) to visualize each step.

Example:
```julia
using POMDPs
using POMDPModels
using POMDPTools
using ElectronDisplay
ElectronDisplay.CONFIG.single_window = true

ds = DisplaySimulator()
m = SimpleGridWorld()
simulate(ds, m, RandomPolicy(m))
```

```@docs
DisplaySimulator
```

### Display-specific tips

The following tips may be helpful when using particular displays.

#### Jupyter notebooks

By default, in a Jupyter notebook, the visualizations of all steps are displayed in the output box one after another. To make the output animated instead, where the image is overwritten at each step, one may use
```julia
DisplaySimulator(predisplay=(d)->IJulia.clear_output(true))
```

#### ElectronDisplay

By default, ElectronDisplay will open a new window for each new step. To prevent this, use
```julia
ElectronDisplay.CONFIG.single_window = true
```
