# [Defining Basic (PO)MDP Properties](@id basic)

In addition to the [dynamic decision network (DDN)](@ref Dynamic-decision-networks) that defines the state and observation dynamics, a POMDPs.jl problem definition will include definitions of various other properties. Each of these properties is defined by implementing a new method of an interface function for the problem.

To use most solvers, it is only necessary to implement a few of these functions.

## Spaces

The state, action and observation spaces are defined by the following functions:

- [`states`](@ref)`(pomdp)`
- [`actions`](@ref)`(pomdp[, s])`
- [`observations`](@ref)`(pomdp)`

The object returned by these functions should implement part or all of the [interface for spaces](@ref space-interface). For discrete problems, a vector is appropriate.

It is often important to limit the action space based on the current state, belief, or observation. 
This can be accomplished with the [`actions`](@ref)`(m, s)` or [`actions`](@ref)`(m, b)` function.
See [Histories associated with a belief](@ref) and the [`history`](@ref) and [`currentobs`](@ref) docstrings for more information.

## Discount Factor

[`discount`](@ref)`(pomdp)` should return a number between 0 and 1 to define the discount factor.

## Terminal States

If a problem has terminal states, they can be specified using the [`isterminal`](@ref) function. If a state `s` is terminal [`isterminal`](@ref)`(pomdp, s)` should return `true`, otherwise it should return `false`.

In POMDPs.jl, no actions can be taken from terminal states, and no additional rewards can be collected, thus, the value function for a terminal state is zero. POMDPs.jl does not have a mechanism for defining terminal rewards apart from the [`reward`](@ref) function, so the problem should be defined so that any terminal rewards are collected as the system transitions into a terminal state.

## Indexing

For discrete problems, some solvers rely on a fast method for finding the index of the states, actions, or observations in an ordered list. These indexing functions can be implemented as
- [`stateindex`](@ref)`(pomdp, s)`
- [`actionindex`](@ref)`(pomdp, a)`
- [`obsindex`](@ref)`(pomdp, o)`

Note that the converse mapping (from indices to states) is not part of the POMDPs interface. A solver will typically create a vector containing all the states to define it.

## Conversion to vector types

Some solvers (notably those that involve deep learning) rely on the ability to represent states, actions, and observations as vectors. To define a mapping between vectors and custom problem-specific representations, implement the following functions (see docstring for signature):

- [`convert_s`](@ref)
- [`convert_a`](@ref)
- [`convert_o`](@ref)
