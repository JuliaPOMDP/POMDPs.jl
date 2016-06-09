# Defining a POMDP

The expressive nature of POMDPs.jl gives problem writers the flexiblity to write their problem in many forms. In this
section we will take a look at two ways to write a discrete problem, and a way of writing a continuous problem. 

## Functional Form POMDP
The first, and most straighforward way to define a POMDP problem is to implement the model functions that you may need.
For example, all POMDPs will need ```transition```, ```reward```, and ```observation``` functions. In this example we'll
start with the simple Tiger POMDP problem. We want to use the SARSOP solver to compute a policy. To use a solver from
JuliaPOMDP, a problem writer must define a set of functions required by the solver. To see what functions are required
by SARSOP, check out its documentation [here](#href). 

Let's first define the Tiger POMDP type.

```julia
using POMDPs # load the interface
type TigerPOMDP <: POMDP{Bool, Int64, Bool} # parametarized inheritance POMDP{state, action, observation}
    r_listen::Float64 # reward for listening (negative)
    r_findtiger::Float64 # reward for finding the tiger (negative)
    r_escapetiger::Float64 # reward for escaping
    p_listen_correctly::Float64 # probbility that we hear the tiger correctly
    discount_factor::Float64 # discount factor
end
TigerPOMDP() = TigerPOMDP(-1.0, -100.0, 10.0, 0.85, 0.95) # default contructor
```

Notice that the ```TigerPOMDP``` is inheriting from the abstract ```POMDP``` type that comes from POMDPs.jl. The abstract ```POMDP``` is parametarized by a ```Bool```, ```Int64```, ```Bool``` combination with the syntax ```TigerPOMDP <: POMDP{Bool, Int64, Bool}```. The parametarization defines how we choose to represent the state, actions, and observations in our problem. In the ```TigerPOMDP``` we use a boolean to represent our states and observations (because there are two of each) and an integer to represent our actions (because there are 3). If you wanted to create a custom concrete type to represent your states, actions, or observations you could do that as well. Let's say we made a type to represent our states called ```AwesomeTigerState```. That type could contain integers, floats, arrays, or other complex data structures (depending on what's convenient). We would then parametrize the Tiger POMDP in the following way: ```type TigerPOMDP <: POMDP{AwesomeTigerState, Int64, Bool}```.

Now, let's consider another important component of POMDPs, probability distributions. In the POMDPs.jl interface, we think in terms of distribution types. We want to be able to sample from these distriubtions and compute their probability masses or densities. In the Tiger POMDP, our distriubtions are over binary variables (boolean state or observation), so we can implement a simple version of a Bernoulli distribution.

```julia
type TigerDistribution <: AbstractDistribution # inherits from a POMDPs.jl abstract type
    p::Float64 # probability of 1
    it::Vector{Bool} # pre-allocate the domain of the distriubtion
end
TigerDistribution() = TigerDistribution(0.5, [true, false]) # default constructo

iterator(d::TigerDistribution) = d.it # convenience function used by discrete solvers (iterator over the discrete distriubtion)
```

Let's implement the pdf and rand function that returns the probability mass and samples from the distribution.

```julia
# returns the probability mass 
function pdf(d::TigerDistribution, so::Bool)
    so ? (return d.p) : (return 1.0-d.p)
end

# samples the dsitribution
rand(rng::AbstractRNG, d::TigerDistribution, s::Bool) = rand(rng) <= d.p
```

We also want some convenience functions for initializing the distriubtions.

```julia 
create_transition_distribution(::TigerPOMDP) = TigerDistribution()
create_observation_distribution(::TigerPOMDP) = TigerDistribution()
```

Let's define our transition, observation, and reward functions.

```julia
function transition(pomdp::TigerPOMDP, s::Bool, a::Int64, d::TigerDistribution=create_transition_distribution(pomdp))
    # Resets the problem after opening door; does nothing after listening        
    if a == 1 || a == 2
        d.p = 0.5
    elseif s
        d.p = 1.0
    else
        d.p = 0.0
    end
    d
end

function observation(pomdp::TigerPOMDP, s::Bool, a::Int64, d::TigerDistribution=create_observation_distribution(pomdp))
    # correct observation wiht prob pc        
    pc = pomdp.p_listen_correctly
    if a == 0
        s ? (d.p = pc) : (d.p = 1.0-pc)
    else
        d.p = 0.5
    end
    d
end
# convenience function
function observation(pomdp::TigerPOMDP, s::Bool, a::Int64, sp::Bool, d::TigerDistribution=create_observation_distribution(pomdp))
    return observation(pomdp, s, a, d)
end

function reward(pomdp::TigerPOMDP, s::Bool, a::Int64)
    # rewarded for escaping, penalized for listening and getting caught
    r = 0.0
    a == 0 ? (r+=pomdp.r_listen) : (nothing)
    if a == 1
        s ? (r += pomdp.r_findtiger) : (r += pomdp.r_escapetiger)
    end
    if a == 2
        s ? (r += pomdp.r_escapetiger) : (r += pomdp.r_findtiger)
    end
    return r
end
# convenience function
reward(pomdp::TigerPOMDP, s::Bool, a::Int64, sp::Bool) = reward(pomdp, s, a)
```

The last important component of a POMDP are the spaces. There is a special ```AbstractSpace``` type in POMDPs.jl which all spaces inherit from. We define the state, action, and observation spaces below as well as functions for intializing them and sampling from them.

```julia
# STATE SPACE
type TigerStateSpace <: AbstractSpace
    states::Vector{Bool} # states are boolean
end
# initialize the state space
states(::TigerPOMDP) = TigerStateSpace([true, false])
# for iterating over discrete spaces
iterator(space::TigerStateSpace) = space.states
dimensions(::TigerStateSpace) = 1
# sample from the state sapce
rand(rng::AbstractRNG, space::TigerStateSpace, s::Bool) = rand(rng) > 0.5 ? (return true) : (return false)

# ACTION SPACE
type TigerActionSpace <: AbstractSpace
    actions::Vector{Int64} # three possible actions
end
# initialize the action space
actions(::TigerPOMDP) = TigerActionSpace([0,1,2])
# iterate of the action space
iterator(space::TigerActionSpace) = space.actions
dimensions(::TigerActionSpace) = 1
# sample from the aciton space
rand(rng::AbstractRNG, space::TigerActionSpace, a::Int64) = rand(rng, 0:2)

# OBSERVATION SPACE
type TigerObservationSpace <: AbstractSpace
    obs::Vector{Bool}
end
# initialize
observations(::TigerPOMDP) = TigerObservationSpace([true, false])
# iterate over obs space
iterator(space::TigerObservationSpace) = space.obs
dimensions(::TigerObservationSpace) = 1
# sample from the obs sapce
rand(rng::AbstractRNG, space::TigerObservationSpace, s::Bool) = rand(rng) > 0.5 ? (return true) : (return false)
```

The last important component of a POMDP is the initial distribution over the state space. In POMDPs.jl we make a strong distinction
between this distribution and a belief. In most literature these two concepts are considered the same. However, in
most general terms, a belief is something that is mapped to an action using a POMDP policy. If the policy is represented
as something other than alpha-vectors (a policy graph, tree, or a reccurent neural netowrk to give a few examples), it
may not make sense to think of a belief as a probability distribution over the state space. Thus, in POMDPs.jl we
abstract the concept of a belief beyond a probability distribution (of course it can be a probability distriubtion if it
makes sense). 

In order to reconcile this difference, each policy has a function called ```initialize_belief``` which takes in an
initial state distirubtion (this is a probability distribution over the state space) and a policy, and converts the
distribution into what we call a belief in POMDPs.jl - a representation of a POMDP that is mapped to an action using the
policy. 

Let's define the initial state distribution function for our POMDP.

```julia
initial_state_distribution(pomdp::TigerPOMDP) = TigerDistribution(0.5, [true, false])
```

Now that've defined all the main components, we need to wrap up our model by creating some convenience functions below.

```julia
# initialization functions
create_state(::TigerPOMDP) = zero(Bool)
create_observation(::TigerPOMDP) = zero(Bool)
create_action(::TigerPOMDP) = zero(Int64)

# for discrete problems
n_states(::TigerPOMDP) = 2
n_actions(::TigerPOMDP) = 3
n_observations(::TigerPOMDP) = 2

# for indexing discrete states
state_index(::TigerPOMDP, s::Bool) = Int64(s) + 1

discount(pomdp::TigerPOMDP) = pomdp.discount_factor
```

Now that we've defined all these functions, we can use one of the JuliaPOMDP solvers to compute and evaluate a policy. 

```julia
using QMDP, POMDPToolbox

pomdp = TigerPOMDP()
solver = QMDPSolver()
policy = solve(solver, pomdp)

init_dist = initial_state_distribution(pomdp)
hist = HistoryRecorder(max_steps=100) # from POMDPToolbox
r = simulate(hist, pomdp, policy, belief_updater, init_dist) # run 100 step simulation
```

Please note that you do not need to define all the functions for most solvers. If you want to use an individual solver, you usually need only a subset of what's above. 

## Tabular Form POMDP

Another way to define discrete POMDP problems is by writing them in tabular form. Specifically, if you can write the
transition and observation probabilities as well as the rewards in matrix form, you can use the ```DiscreteMDP``` or
```DiscretePOMDP``` types form ```POMDPModels``` which automatically implements all the functions you'll need for you.
Let's do this with the Tiger POMDP.

```julia
using POMDPModels

# write out the matrix forms

# REWARDS
R = [-1. -100 10; -1 10 -100] # |S|x|A| state-action pair rewards

# TRANSITIONS
T = zeros(2,3,2) # |S|x|A|x|S|, T[s', a, s] = p(s'|a,s)
T[:,:,1] = [1. 0.5 0.5; 0 0.5 0.5]
T[:,:,2] = [0. 0.5 0.5; 1 0.5 0.5]

# OBSERVATIONS
O = zeros(2,3,2) # |O|x|A|x|S|, O[o, a, s] = p(o|a,s)
O[:,:,1] = [0.85 0.5 0.5; 0.15 0.5 0.5]
O[:,:,2] = [0.15 0.5 0.5; 0.85 0.5 0.5]

discount = 0.95
pomdp = DiscretePOMDP(T, R, O, discount)

# solve the POMDP the same way
solver = SARSOPSolver()
policy = solve(solver, pomdp)
```

It is usually fairly simple to define smaller problems in the tabular form. However, for larger problems it can be
tedious and the functional form may be preffered. You can usually use any supported POMDP solver to sovle these types of problems (the performance of the policy may vary however - SARSOP will usually outperform QMDP). 

## Continous POMDP

Within the POMDPs.jl interface, we can also define problems with continuous spaces. 
There are a few solvers that can handle these types of problems, namely, MCVI and POMCP (with some tunning). Light-Dark problem here. What should we say about bounds? 














