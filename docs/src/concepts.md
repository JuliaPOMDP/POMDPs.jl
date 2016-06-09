# Concepts and Architecture

POMDPs.jl aims to coordinate the development of three software components: 1) a problem, 2) a solver, 3) an experiment.
Each of these components has a set of abstract types associated with it and a set of functions that allow a user to define each component's behavior in a standardized way.
An outline of the architecture is shown below.

![concepts](figures/concepts.png)

The MDP and POMDP types are associated with the problem definition.
The Solver and Policy types are associated with the solver or decision-making agent.
Typically, the Updater type is also associated with the solver, but a solver may sometimes be used with an updater that was implemented separately.
The Simulator type is associated with the experiment. 

## POMDPs and MDPs

An MDP is a definition of a problem where the state of the problem is fully observable.
Mathematically, an MDP is a tuple (S,A,T,R), where S is the state space, A is the action space, T is a function that defines the probability of transitioning to each state given the state and action at the previous time, and R is a reward function mapping every possible transition (s,a,s') to a real reward value.
For more information see a textbook such as [1].
In POMDPs.jl an MDP is represented by a concrete subtype of the `MDP` abstract type and a set of methods that define each of its components.
S and A are defined by implementing methods of the `states` and `actions` functions for the `MDP` subtype, though for some solvers, the state space does not need to be explicitly defined.
T and R are defined by implementing methods of the `transition` and `reward` functions. 

A POMDP is a problem definition where the state is only partially observable by the decision making agent.
Mathematically, a POMDP is a tuple (S,A,T,R,O,Z) where S, A, T, and R have the same meaning as in the MDP case, Z is the set of observations that the decision-making agent might receive and O is a function defining the probability of receiving each observation at a transition.
In POMDPs.jl, a POMDP is represented by a concrete subtype of the `POMDP` abstract type, `Z` may be defined by the `observations` function (though an explicit definition is often not required), and `O` is defined by implementing a method of `observation` for the POMDP type.

POMDPs.jl also contains functions for defining optional problem behavior such as a discount factor or a set of terminal states.

It is important to note that, in some cases, it is difficult to explicitly represent the transition and observation distributions for a problem but easy to generate a sampled next state or observation. In these cases it may be significantly easier to use the `GenerativeModels.jl` interface extension *instead of* implementing methods of `transition` and `observation`.


## Beliefs and Updaters

In a POMDP domain, the decision-making agent does not have complete information about the state of the problem, so the agent can only make choices based on its "belief" about the state.
In the POMDP literature, the term "belief" is typically defined to mean a probability distribution over all possible states of the system.
However, in practice, the agent often makes decisions based on an incomplete or lossy record of past observations that has a structure much different from a probability distribution.
For example, if the agent is represented by a finite-state controller as is the case for Monte-Carlo Value Iteration [2], the belief is the controller state, which is a node in a graph.
Another example is an agent represented by a recurrent neural network.
In this case, the agent's belief is the state of the network.
In order to accommodate a wide variety of decision-making approaches, in POMDPs.jl, we use the term "belief" to denote the set of information that the agent makes a decision on, which could be an exact state distribution, an action-observation history, a set of weighted particles, or the examples mentioned before.
In code, the belief can be represented by any built-in or user defined type.

When an action is taken and a new observation is received, the belief is updated by the belief updater.
In code, a belief updater is represented by a concrete subtype of the `Updater` abstract type, and the `update` function defines how the belief is updated when a new observation is received.

Although the agent may use a specialized belief structure to make decisions, the information initially given to the agent about the state of the problem is usually most conveniently represented as a state distribution, thus the `initialize_belief` function is provided to convert a state distribution to a specialized belief structure that an updater can work with.

In some cases, the belief structure is closely related to the solution technique, so it will be implemented by the programmer who writes the solver.
In other cases, the agent can use a variety of belief structures to make decisions, so a domain-specific updater implemented by the programmer that wrote the problem description may be appropriate.
Finally, some advanced generic belief updaters such as particle filters may be implemented by a third party.

## Solvers and Policies

Sequential decision making under uncertainty involves both online and offline calculations. In the broad sense, the term "solver" refers to both the online and ...

A policy is a mapping from every belief that an agent might take to an action. A policy is represented in code by a concrete subtype of the `Policy` abstract type ...


[1] *Decision Making Under Uncertainty: Theory and Application* by Mykel J. Kochenderfer, MIT Press, 2015

[2] Bai, H., Hsu, D., & Lee, W. S. (2014). Integrated perception and planning in the continuous space: A POMDP approach. The International Journal of Robotics Research, 33(9), 1288-1302


