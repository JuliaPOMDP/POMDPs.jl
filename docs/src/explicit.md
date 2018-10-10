# [Explicit POMDP Interface](@id explicit_doc)

When using the explicit interface, the transition and observation probabilities must be explicitly defined. This section gives examples of two ways to define a discrete POMDP that is widely used in the literature.
Note that there is no requirement that a problem defined using the explicit interface be discrete; it is equally easy to define a continuous problem using the explicit interface.

## Functional Form Explicit POMDP

The functional form of the explicit interface contains a small collection of functions to model transition and observation distributions. The explicit interface functions are the following (note that this is not actual julia code):
```julia
transition(pomdp, s, a) 
observation(pomdp, a, sp)
initialstate_distribution(pomdp)
isterminal(pomdp)
```

The functions `transition`, `observation`, and `initialstate_distribution` return a distribution over states or observations. This makes it possible to sample a state from this distribution as well as computing the pdf of a state given this distribution. `transition` represents the probability distribution of the next state given a current state s and action a. `observation` represents the probability distribution of an observation given the true underlying state sp and action a. 

State, action and observation spaces are respectively represented by the output of the following functions:
```julia
states(pomdp)
actions(pomdp)
observations(pomdp)
```


For MDPs, the observation related functions are not needed. 

### Discrete problems 


In discrete problems, the `states`, `actions`, and `observations` functions can be used to iterate over the spaces (for discrete spaces). They can output a collection (such as a vector of states), or alternatively an object that one can iterate over if storing the state space in a collection is not practical. 

Additional functions allow the problem writer to specify the index of a given element (state, action or observation) in its corresponding space. The functions starting with `n_` are used to specify how many elements are in a discrete space.
```julia
stateindex(pomdp, s)
actionindex(pomdp, a)
obsindex(pomdp, o)
n_states(pomdp)
n_actions(pomdp)
n_observations(pomdp)
```

### Example 

An example of defining a problem using the explicit interface can be found at: 
https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-POMDP-with-the-Explicit-Interface.ipynb


## Tabular Form Explicit POMDP

The `TabularPOMDP` problem representation provided by [POMDPModels.jl](https://github.com/JuliaPOMDP/POMDPModels.jl) allows you to specify discrete POMDP problems in tabular form. It requires specifying the transition probabilites, observation probabilities, and rewards in matrix form and implements automatically all required functionality. The states, observations and actions are represented by integers.

The transition matrix is 3 dimensional of size $|\mathcal{S}|\times |\mathcal{A}| \times |\mathcal{S}|$, then `T[sj, a, si]` corresponds to the probability of ending in `sj` while taking action `a` in `si`. The observation matrix is also 3 dimensional of size $|\mathcal{O}| \times |\mathcal{A}| \times |\mathcal{S}|$, `O[o, a, sp]` represents the probability of observing `o` in in state `sp` and action `a`. The reward matrix is 2 dimensional of size $|\mathcal{S}|\times |\mathcal{A}|$, where `R[s, a]` is the reward obtained when taking action `a` in state `s`. 

The analogous `TabularMDP` allows to model discrete MDP in tabular form.

It is often easiest to define smaller problems in tabular form. However, for larger problems it can be tedious and the functional form may be preferred.

### Example 

An example of defining a problem using the tabular representation can be found at: 
https://github.com/JuliaPOMDP/POMDPExamples.jl/blob/master/notebooks/Defining-a-tabular-POMDP.ipynb
