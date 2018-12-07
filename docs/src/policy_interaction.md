# Interacting with Policies

A solution to a POMDP is a policy that maps beliefs or action-observation histories to actions. In POMDPs.jl, these are represented by [`Policy`](@ref) objects. See [Solvers and Policies](@ref) for more information about what a policy can represent in general.

One common task in evaluating POMDP solutions is examining the policies themselves. Since the internal representation of a policy is an esoteric implementation detail, it is best to interact with policies through the `action` and `value` interface functions. There are three relevant methods

- [`action(policy, s)`](@ref) returns the best action (or one of the best) for the given state or belief.
- [`value(policy, s)`](@ref) returns the expected sum of future rewards if the policy is executed.
- [`value(policy, s, a)`](@ref) returns the "Q-value", that is, the expected sum of rewards if action a is taken on the next step and then the policy is executed.

Note that the quantities returned by these functions are what the policy/solver expects to be the case after its (usually approximate) computations; they may be far from the true value if the solution is not exactly optimal.
