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
using POMDPToolbox
probability_check(pomdp) # checks that both observation and transition functions give probs that sum to unity
obs_prob_consistancy_check(pomdp) # checks the observation probabilities
trans_prob_consistancy_check(pomdp) # check the transition probabilities
```

If these throw an error, you may need to fix your `transition` or `observation` functions. 


## Why do I need to put type assertions pomdp::POMDP into the function signature?

Specifying the type in your function signature allows Julia to call the appropriate function when your custom type is
passed into it.
For example if a POMDPs.jl solver calls `states` on the POMDP that you passed into it, the correct `states` function
will only get dispatched if you specified that the `states` function you wrote works with your POMDP type. Because Julia
supports multiple-dispatch, these type assertion are a way for doing object-oriented programming in Julia.


## Why are all the solvers in seperate modules?

We did not put all the solvers and support tools into POMDPs.jl, because we wanted POMDPs.jl to be a lightweight
interface package.
This has a number of advantages. The first is that if a user only wants to use a few solvers from the
JuliaPOMDP organization, they do not have to install all the other solvers and their dependencies.
The second advantage is that people who are not directly part of the JuliaPOMDP organization can write their own solvers
without going into the source code of other solvers. This makes the framework easier to adopt and to extend.




