# Spaces and Distributions

Two important components of the definitions of MDPs and POMDPs are *spaces*, which specify the possible states, actions, and observations in a problem and *distributions*, which define probability distributions. In order to provide for maximum flexibility spaces and distributions may be of any type (i.e. there are no abstract base types). Solvers and simulators will interact with space and distribution types using the functions defined below.

## Spaces

A space object should contain the information needed to define the set of all possible states, actions or observations. The implementation will depend on the attributes of the elements. For example, if the space is continuous, the space object may only contain the limits of the continuous range. In the case of a discrete problem, a vector containing all states is appropriate for representing a state.

The following functions may be called on a space object (Click on a function to read its documentation):

- [`rand`](@ref)
- [`dimensions`](@ref)
- [`sampletype`](@ref)

## Distributions

A distribution object represents a probability distribution.

The following functions may be called on a distribution object (Click on a function to read its documentation):

- [`rand`](@ref)
- [`support`](@ref)
- [`sampletype`](@ref)
- [`pdf`](@ref)
- [`mode`](@ref)
- [`mean`](@ref)
