# Concepts and Architecture

## Belief

The last important component of a POMDP is the initial distribution over the state of the agent. In POMDPs.jl we make a strong distinction
between this distribution and a belief. In most literature these two concepts are considered the same. However, in
most general terms, a belief is something that is mapped to an action using a POMDP policy. If the policy is represented
as something other than alpha-vectors (a policy graph, tree, or a reccurent neural netowrk to give a few examples), it
doesn't make sense to think of a belief as a probability distribution over the state space. Thus, in POMDPs.jl we
abstract the concept of a belief beyond a probability distribution (of course it can be a probability distriubtion if it
makes sense). 

In order to reconcile this difference, each policy has a function called ```initialize_belief``` which takes in an
initial state distirubtion (this is a probability distribution over the state space of a POMDP) and a policy, and converts the
distribution into what we call a belief in POMDPs.jl - a representation of a POMDP that is mapped to an action using the
policy. 


