# Frequently Asked Questions (FAQ)

## Why am I getting a "No implementation for ..." error?

You will typically see this error when you haven't implemented a function that a solver is trying to call.
For example, if you are using the QMDP solver, and have not implemented `num_states` for your POMDP, you will see the no
implementation error. To fix the error, you need to create a `num_states` function that takes in your POMDP. To see the
required functions for a given solver you can run:

```julia
using QMDP
QMDP.required_methods()
```

## How do I save my policies?

We recommend using [JLD](https://github.com/JuliaIO/JLD.jl) to save the whole policy object. This is a simple and
fairly efficient way to save Julia objects. JLD uses the HDF5 format underneath. To save a computed policy, run:

```julia
using JLD
save("my_policy.jld", "policy", policy)
```
## Why isn't the solver working?

There could be a number of things that are going wrong. Remeber, POMDPs can be failry hard to work with, but don't
panic. 
If you have a discrete POMDP or MDP and you're using a solver that requires the explicit transition probabilities
(you've implemented a `pdf` function), the first thing to try is make sure that your probability masses sum up to unity. 
We've provide some tools in POMDPToolbox that can check this for you.
If you have a POMDP called pomdp, you can run the checks by doing the following:

```julia
using POMDPTesting
probability_check(pomdp) # checks that both observation and transition functions give probs that sum to unity
obs_prob_consistency_check(pomdp) # checks the observation probabilities
trans_prob_consistency_check(pomdp) # check the transition probabilities
```

If these throw an error, you may need to fix your `transition` or `observation` functions. 


## Why do I need to put type assertions pomdp::POMDP into the function signature?

Specifying the type in your function signature allows Julia to call the appropriate function when your custom type is
passed into it.
For example if a POMDPs.jl solver calls `states` on the POMDP that you passed into it, the correct `states` function
will only get dispatched if you specified that the `states` function you wrote works with your POMDP type. Because Julia
supports multiple-dispatch, these type assertion are a way for doing object-oriented programming in Julia.


## Why are all the solvers in separate modules?

We did not put all the solvers and support tools into POMDPs.jl, because we wanted POMDPs.jl to be a lightweight
interface package.
This has a number of advantages. The first is that if a user only wants to use a few solvers from the
JuliaPOMDP organization, they do not have to install all the other solvers and their dependencies.
The second advantage is that people who are not directly part of the JuliaPOMDP organization can write their own solvers
without going into the source code of other solvers. This makes the framework easier to adopt and to extend.

## How can I implement terminal actions?

Terminal actions are actions that cause the MDP to terminate without generating a new state. POMDPs.jl handles terminal conditions via the `isterminal` function on states, and does not directly support terminal actions. If your MDP has a terminal action, you need to implement the model functions accordingly to generate a terminal state. In both generative and explicit cases, you will need some dummy state, say `spt`, that can be recognized as terminal by the `isterminal` function. One way to do this is to give `spt` a state value that is out of bounds (e.g. a vector of `NaN`s or `-1`s) and then check for that in `isterminal`, so that this does not clash with any conventional termination conditions on the state.

If a terminal action is taken, regardless of current state, the `transition` function should return a distribution with only one next state, `spt`, with probability 1.0. In the generative case, the new state generated should be `spt`. The `reward` function or the `r` in `generate_sr` can be set according to the cost of the terminal action.
