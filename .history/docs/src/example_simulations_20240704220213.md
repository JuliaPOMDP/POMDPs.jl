
# Simulations Examples

In these simulation examples, we will use the crying baby POMDPs defined in the [Defining a POMDP](@ref) section (i.e. [`quick_crying_baby_pomdp`](@ref quick_crying), [`explicit_crying_baby_pomdp`](@ref explicit_crying), [`gen_crying_baby_pomdp`](@ref gen_crying), and [`tabular_crying_baby_pomdp`](@ref tab_crying)).

```@setup crying_sim
include("examples/crying_baby_examples.jl")
include("examples/crying_baby_solvers.jl")
```

## Stepthrough
The stepthrough simulater provides a window into the simulation with a for-loop syntax.

Within the body of the for loop, we have access to the belief, the action, the observation, and the reward, in each step. We also calculate the sum of the rewards in this example, but note that this is _not_ the _discounted reward_.

```@example crying_sim
function run_step_through_simulation() # hide
policy = RandomPolicy(quick_crying_baby_pomdp)
r_sum = 0.0
step = 0
for (b, s, a, o, r) in stepthrough(quick_crying_baby_pomdp, policy, DiscreteUpdater(quick_crying_baby_pomdp), "b,s,a,o,r"; max_steps=4)
    step += 1
    println("Step $step")
    println("b = sated => $(b.b[1]), hungry => $(b.b[2])")
    @show s
    @show a
    @show o
    @show r
    r_sum += r
    @show r_sum
    println()        
end
end #hide

run_step_through_simulation() # hide
```

## Rollout Simulations
While stepthrough is a flexible and convenient tool for many user-facing demonstrations, it is often less error-prone to use the standard simulate function with a `Simulator` object. The simplest Simulator is the `RolloutSimulator`. It simply runs a simulation and returns the discounted reward. 

```@example crying_sim
function run_rollout_simulation() # hide
policy = RandomPolicy(explicit_crying_baby_pomdp)
sim = RolloutSimulator(max_steps=10)
r_sum = simulate(sim, explicit_crying_baby_pomdp, policy)
println("Total discounted reward: $r_sum")
end # hide
run_rollout_simulation() # hide
```

## Recording Histories
Sometimes it is important to record the entire history of a simulation for further examination. This can be accomplished with a `HistoryRecorder`.

```@example crying_sim
policy = RandomPolicy(tabular_crying_baby_pomdp)
hr = HistoryRecorder(max_steps=5)
history = simulate(hr, tabular_crying_baby_pomdp, policy, DiscreteUpdater(tabular_crying_baby_pomdp), Deterministic(1))
nothing # hide
```

The history object produced by a `HistoryRecorder` is a `SimHistory`, documented in the POMDPTools simulater section [Histories](@ref). The information in this object can be accessed in several ways. For example, there is a function:
```@example crying_sim
discounted_reward(history)
```
Accessor functions like `state_hist` and `action_hist` can also be used to access parts of the history:
```@example crying_sim
state_hist(history)
```
``` @example crying_sim
collect(action_hist(history))
```

Keeping track of which states, actions, and observations belong together can be tricky (for example, since there is a starting state, and ending state, but no action is taken from the ending state, the list of actions has a different length than the list of states). It is often better to think of histories in terms of steps that include both starting and ending states.

The most powerful function for accessing the information in a `SimHistory` is the `eachstep` function which returns an iterator through named tuples representing each step in the history. The `eachstep` function is similar to the `stepthrough` function above except that it iterates through the immutable steps of a previously simulated history instead of conducting the simulation as the for loop is being carried out.

```@example crying_sim
function demo_eachstep(sim_history) # hide
r_sum = 0.0
step = 0
for step_i in eachstep(sim_history, "b,s,a,o,r")
    step += 1
    println("Step $step")
    println("step_i.b = sated => $(step_i.b.b[1]), hungry => $(step_i.b.b[2])")
    @show step_i.s
    @show step_i.a
    @show step_i.o
    @show step_i.r
    r_sum += step_i.r
    @show r_sum
    println()
end
end # hide 
demo_eachstep(history) # hide
```

## Parallel Simulations
It is often useful to evaluate a policy by running many simulations. The parallel simulator is the most effective tool for this. To use the parallel simulator, first create a list of `Sim` objects, each of which contains all of the information needed to run a simulation. Then then run the simulations using `run_parallel`, which will return a `DataFrame` with the results.

In this example, we will compare the performance of the polcies we computed in the [Using Different Solvers](@ref) section (i.e. `sarsop_policy`, `pomcp_planner`, and `heuristic_policy`). To evaluate the policies, we will run 100 simulations for each policy. We can do this by adding 100 `Sim` objects of each policy to the list.

```@example crying_sim
using DataFrames 
using StatsBase: std

# Defining paramters for the simulations
number_of_sim_to_run = 100
max_steps = 20
starting_seed = 1

# We will also compare against a random policy
rand_policy = RandomPolicy(quick_crying_baby_pomdp, rng=MersenneTwister(1))

# Create the list of Sim objects
sim_list = []

# Add 100 Sim objects of each policy to the list.
for sim_number in 1:number_of_sim_to_run
    seed = starting_seed + sim_number

    # Add the SARSOP policy
    push!(sim_list, Sim(
        quick_crying_baby_pomdp, 
        rng=MersenneTwister(seed),
        sarsop_policy,
        max_steps=max_steps,
        metadata=Dict(:policy => "sarsop", :seed => seed))
    )

    # Add the POMCP policy
    push!(sim_list, Sim(
        quick_crying_baby_pomdp, 
        rng=MersenneTwister(seed),
        pomcp_planner, 
        max_steps=max_steps,
        metadata=Dict(:policy => "pomcp", :seed => seed))
    )

    # Add the heuristic policy
    push!(sim_list, Sim(
        quick_crying_baby_pomdp, 
        rng=MersenneTwister(seed),
        heuristic_policy, 
        max_steps=max_steps,
        metadata=Dict(:policy => "heuristic", :seed => seed))
    )

    # Add the random policy
    push!(sim_list, Sim(
        quick_crying_baby_pomdp, 
        rng=MersenneTwister(seed),
        rand_policy, 
        max_steps=max_steps,
        metadata=Dict(:policy => "random", :seed => seed))
    )
end

# Run the simulations in parallel
data = run_parallel(sim_list)

# Define a function to calculate the mean and confidence interval
function mean_and_ci(x)
    m = mean(x)
    ci = 1.96 * std(x) / sqrt(length(x))  # 95% confidence interval
    return (mean = m, ci = ci)
end

# Calculate the mean and confidence interval for each policy
grouped_df = groupby(data, :policy)
result = combine(grouped_df, :reward => mean_and_ci => AsTable)

```

By default, the parallel simulator only returns the reward from each simulation, but more information can be gathered by specifying a function to analyze the `Sim`-history pair and record additional statistics. Reference the POMDPTools simulator section for more information ([Specifying information to be recorded](@ref)).