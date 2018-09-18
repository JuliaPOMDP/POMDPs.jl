# Defining a Belief Updater

In this section we list the requirements for defining a belief updater.
For a description of what a belief updater is, see [Concepts and Architecture - Beliefs and Updaters](@ref beliefs_and_updaters).
Typically a belief updater will have an associated belief type, and may be closely tied to a particular policy/planner.

## Defining a Belief Type

A belief object should contain all of the information needed for the next belief update and for the policy to make a decision.
The belief type could be a pre-defined type such as a distribution from `Distributions.jl` or `DiscreteBelief` or `SparseCat` from `POMDPModelTools.jl`, or it could be a custom type.

Often, but not always, the belief will represent a probability distribution.
In this case, the functions in the [distribution interface](@ref Distributions) should be implemented if possible.
Implementing these functions will make the belief usable with many of the policies and planners in the POMDPs.jl ecosystem, and will make it easy for others to convert between beliefs and to interpret what a belief means.

## Defining an Updater

To create an updater, one should define a subtype of the `Updater` abstract type and implement two methods, one to create the initial belief from the problem's initial state distribution and one to perform a belief update:

- [`initialize_belief(updater, d)`](@ref) creates a belief from state distribution `d` appropriate to use with the updater. To extract information from `d`, use the functions from the [distribution interface](@ref Distributions).
- [`update(updater, b, a, o)`](@ref) returns an updated belief given belief `b`, action `a`, and observation `o`. One can usually expect `b` to be the same type returned by [`initialize_belief`](@ref) because a careful user will always call [`initialize_belief`](@ref) before [`update`](@ref), but it would also be reasonable to implement [`update`](@ref) for `b` of a different type if it is desirable to handle multiple belief types.

### Example: History Updater

One trivial type of belief would be the action-observation history, a list containing the initial state distribution and every action taken and observation received.
The history contains all of the information received up to the current time, but it is not usually very useful because most policies make decisions based on a state probability distribution.
Here the belief type is simply the built in `Vector{Any}`, so we need only create the updater and write [`update`](@ref) and [`initialize_belief`](@ref).
Normally, [`update`](@ref) would contain belief update probability calculations, but in this example, we simply append the action and observation to the history.

(Note that this example is designed for readability rather than efficiency.)

```julia
import POMDPs

struct HistoryUpdater <: POMDPs.Updater end

initialize_belief(up::HistoryUpdater, d) = Any[d]

function POMDPs.update(up::HistoryUpdater, b, a, o)
    bp = copy(b)
    push!(bp, a)
    push!(bp, o)
    return bp
end
```

At each step, the history starts with the original distribution, then contains all the actions and observations received up to that point. The example below shows this for the crying baby problem (observations are true/false for crying and actions are true/false for feeding).

```julia
using POMDPPolicies
using POMDPSimulators
using POMDPModels
using Random

pomdp = BabyPOMDP()
policy = RandomPolicy(pomdp, rng=MersenneTwister(1))
up = HistoryUpdater()

# within stepthrough initialize_belief is called on the initial state distribution of the pomdp, then update is called at each step.
for b in stepthrough(pomdp, policy, up, "b", rng=MersenneTwister(2), max_steps=5)
    @show b
end

# output

b = Any[POMDPModels.BoolDistribution(0.0)]
b = Any[POMDPModels.BoolDistribution(0.0), false, false]
b = Any[POMDPModels.BoolDistribution(0.0), false, false, false, false]
b = Any[POMDPModels.BoolDistribution(0.0), false, false, false, false, true, false]
b = Any[POMDPModels.BoolDistribution(0.0), false, false, false, false, true, false, true, false]
```
